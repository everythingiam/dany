CREATE OR REPLACE FUNCTION authorize_user(p_login TEXT, p_password TEXT)
RETURNS JSON AS $$

DECLARE
    validation_result JSON;
    login TEXT;
    new_token UUID;
    existing_token UUID;
BEGIN
    -- Проверка логина и пароля
    validation_result := _is_user_valid(p_login, p_password);

    -- Если проверка не прошла, возвращаем сообщение об ошибке
    IF validation_result->>'status' = 'error' THEN
        RETURN validation_result;
    END IF;

    -- Генерация нового уникального токена
    new_token := gen_random_uuid();

    -- Запись нового токена в таблицу
    INSERT INTO user_tokens (login, token, created_at)
    VALUES (p_login, new_token, NOW());

    RETURN json_build_object(
            'status', 'success',
            'message', 'User authorized',
            'token', new_token
        );
END;
$$ LANGUAGE plpgsql;

create or replace function get_user_data(user_token TEXT)
RETURNS JSON AS $$
DECLARE
    user_login TEXT;
	user_avatar TEXT;
BEGIN
    -- Проверяем, существует ли токен в таблице user_tokens
    SELECT login
    INTO user_login
    FROM user_tokens
    WHERE token = user_token;

    -- Если логин не найден, возвращаем сообщение об ошибке
    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid token or user not found.'
        );
    END IF;

     -- Получаем значение avatar из таблицы users
    SELECT avatar
    INTO user_avatar
    FROM users
    WHERE login = user_login;

    -- Возвращаем успешное сообщение с логином и аватаром
    RETURN json_build_object(
        'status', 'success',
        'login', user_login,
        'avatar', user_avatar
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_players(p_user_token TEXT, p_room_token TEXT)
RETURNS JSON AS $$
DECLARE
    -- Переменные для проверки токена
    room_check JSON;

    -- Временные переменные для хранения данных
    players_info JSONB;
BEGIN
    -- Проверяем валидность токена вызывающего
    room_check := _is_token_valid(p_user_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Получаем список игроков из таблицы users_in_room
    SELECT jsonb_agg(jsonb_build_object('login', uir.login))
    INTO players_info
    FROM users_in_room uir
    WHERE uir.room_token = p_room_token;

    -- Если игроков не найдено
    IF players_info IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'No players found in the specified room.'
        );
    END IF;

    -- Получаем логины и аватарки из таблицы users
    RETURN json_build_object(
        'status', 'success',
        'players', (
            SELECT jsonb_agg(jsonb_build_object('login', u.login, 'avatar', u.avatar))
            FROM users u
            WHERE u.login IN (
                SELECT uir.login
                FROM users_in_room uir
                WHERE uir.room_token = p_room_token
            )
        )
    );
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION register_user(p_login TEXT, p_password TEXT)
RETURNS JSON AS $$
BEGIN
    -- Проверяем, существует ли пользователь
    IF EXISTS (SELECT 1 FROM Users WHERE login = p_login) THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Nickname taken'
        );
    END IF;

    -- Проверяем длину логина
    IF LENGTH(p_login) < 3 THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Short nickname'
        );
    END IF;

    -- Проверяем длину пароля
    IF LENGTH(p_password) < 3 THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Short password'
        );
    END IF;

    -- Добавляем нового пользователя с хешированным паролем
    INSERT INTO Users (login, passhash)
    VALUES (
        p_login,
        encode(sha256(p_password::BYTEA), 'hex') -- Хеш пароля в читаемом формате
    );

    -- После успешной регистрации вызываем процедуру авторизации
    RETURN authorize_user(p_login, p_password);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION check_user(p_token TEXT)
RETURNS JSON AS $$
BEGIN
    return _is_token_valid(p_token);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION delete_user(
    p_token TEXT
) RETURNS JSON AS $$

DECLARE
    user_login TEXT;
    room_check JSON;
BEGIN
    -- Проверяем валидность токена
    room_check := _is_token_valid(p_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Получаем логин пользователя по токену
    SELECT ut.login
    INTO user_login
    FROM user_tokens ut
    WHERE ut.token = p_token;

    -- Проверяем, найден ли пользователь
    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'User not found for the provided token'
        );
    END IF;

    -- Удаляем пользователя из таблицы Users
    DELETE FROM Users
    WHERE login = user_login;

    -- Удаляем записи токенов пользователя
    DELETE FROM user_tokens
    WHERE login = user_login;

    -- Успешное удаление
    RETURN json_build_object(
        'status', 'success',
        'message', format('User %s successfully deleted.', user_login)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION end_layout(p_user_token TEXT, p_room_token TEXT)
RETURNS JSON AS $$
DECLARE
    user_login TEXT;
    active_person_id INT;
    user_person_id INT;
    room_check JSON;
    current_phase TEXT;
    room_status JSON;  
    game_started BOOLEAN;
BEGIN
    -- Проверяем валидность токена пользователя
    room_check := _is_token_valid(p_user_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, существует ли комната
    room_check := _is_room_exist(p_room_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, начата ли игра
    SELECT CASE 
               WHEN phase_name != 'waiting' THEN TRUE 
               ELSE FALSE 
           END
    INTO game_started
    FROM game_rooms
    WHERE room_token = p_room_token;

    IF NOT game_started THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Game has not started yet.'
        );
    END IF;

    -- Проверяем текущую фазу комнаты
    SELECT phase_name
    INTO current_phase
    FROM game_rooms
    WHERE room_token = p_room_token;

    IF current_phase != 'layout' THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'The current phase is not "layout".'
        );
    END IF;

    -- Проверяем, истекло ли время
    room_status := _is_time_out(p_room_token);  
    IF room_status->>'status' = 'success' THEN
        PERFORM _switch_phase(p_room_token);
        RETURN json_build_object(
            'status', 'info',
            'message', 'Time is out. Phase switched.'
        );
    END IF;

    -- Получаем логин пользователя по токену
    SELECT login 
    INTO user_login
    FROM user_tokens
    WHERE token = p_user_token;

    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid token: User not found.'
        );
    END IF;

    -- Получаем ID текущей активной личности
    SELECT ap.active_person_id
    INTO active_person_id
    FROM active_people AS ap
    WHERE ap.room_token = p_room_token;

    IF active_person_id IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'No active person found for the user.'
        );
    END IF;

    -- Получаем ID игрока для вызывающего
    SELECT pl.id_player
    INTO user_person_id
    FROM players AS pl
    WHERE pl.login = user_login;

    -- Проверяем, является ли пользователь активной личностью
    IF user_person_id != active_person_id THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'You are not the active person.'
        );
    END IF;

    -- Завершаем текущую фазу
    -- PERFORM _switch_phase(p_room_token);
	perform _set_phase(p_room_token, 'discussion');

    -- Возвращаем успешный результат
    RETURN json_build_object(
        'status', 'success',
        'message', 'Layout ended.'
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION join_room(
    p_user_token TEXT,
    p_room_token TEXT
) RETURNS JSON AS $$

DECLARE
    user_login TEXT;
    current_count INT;
    room_max_amount INT;
    room_check JSON;
BEGIN
    -- Проверяем валидность токена пользователя
    room_check := _is_token_valid(p_user_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, существует ли комната
    room_check := _is_room_exist(p_room_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Получаем логин пользователя из user_tokens
    SELECT login
    INTO user_login
    FROM user_tokens
    WHERE token = p_user_token;

    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'User not found for the provided token.'
        );
    END IF;

    -- Получаем текущее количество людей в комнате
    SELECT COUNT(*) 
    INTO current_count
    FROM users_in_room
    WHERE room_token = p_room_token;

    -- Получаем максимальное количество людей для комнаты
    SELECT max_amount
    INTO room_max_amount
    FROM game_rooms
    WHERE room_token = p_room_token;

    -- Проверяем, превышает ли текущее количество максимум
    IF current_count >= room_max_amount THEN
        RETURN json_build_object(
            'status', 'error',
            'message', format('Room %s is already full. Maximum allowed: %s', p_room_token, room_max_amount)
        );
    END IF;

    -- Пытаемся вставить пользователя в комнату с обработкой конфликта
    INSERT INTO users_in_room (login, room_token)
    VALUES (user_login, p_room_token)
    ON CONFLICT (login, room_token) DO NOTHING;

    -- Проверяем, была ли вставка успешной
    IF NOT FOUND THEN
        RETURN json_build_object(
            'status', 'error',
            'message', format('User %s is already in room %s.', user_login, p_room_token)
        );
    END IF;

    -- Проверяем, достигнуто ли максимальное количество людей в комнате
    IF current_count + 1 = room_max_amount THEN
        room_check := __start_game(p_room_token);
        IF room_check->>'status' = 'error' THEN
            RETURN room_check;
        END IF;

        RETURN json_build_object(
            'status', 'success',
            'message', format('User %s joined room %s. Game started.', user_login, p_room_token)
        );
    END IF;

    -- Логируем успешное добавление
    RETURN json_build_object(
        'status', 'success',
        'message', format('User %s successfully joined the room %s.', user_login, p_room_token)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION leave_room(p_user_token TEXT, p_room_token TEXT) RETURNS JSON AS $$

DECLARE
    user_in_room BOOLEAN;          
    p_login TEXT;                  
    game_phase TEXT;               
    player_count INT;            
    room_check JSON;
BEGIN
    -- Проверяем валидность токена пользователя
    room_check := _is_token_valid(p_user_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, существует ли комната
    room_check := _is_room_exist(p_room_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Получаем логин пользователя по токену
    SELECT login
    INTO p_login
    FROM user_tokens
    WHERE token = p_user_token;

    -- Проверяем, находится ли пользователь в указанной комнате
    SELECT EXISTS (
        SELECT 1
        FROM users_in_room
        WHERE login = p_login AND room_token = p_room_token
    ) INTO user_in_room;

    IF NOT user_in_room THEN
        RETURN json_build_object(
            'status', 'error',
            'message', format('User %s is not in room %s', p_login, p_room_token)
        );
    END IF;

    -- Получаем текущую фазу игры и количество игроков в комнате
    SELECT gr.phase_name, COUNT(ur.login)
    INTO game_phase, player_count
    FROM game_rooms gr
    JOIN users_in_room ur ON gr.room_token = ur.room_token
    WHERE gr.room_token = p_room_token
    GROUP BY gr.phase_name;

    -- Удаляем пользователя из комнаты
    DELETE FROM users_in_room
    WHERE login = p_login AND room_token = p_room_token;

    RAISE NOTICE 'User %s successfully left the room %s', p_login, p_room_token;

    -- Если игра идет (фаза НЕ 'waiting') и игроков стало меньше 3, завершаем игру
    IF game_phase <> 'waiting' AND player_count - 1 < 3 THEN
        RAISE NOTICE 'There are less than 3 players now. Game ends.';
        PERFORM _end_game(p_room_token);

        RETURN json_build_object(
            'status', 'success',
            'message', 'Game ended due to insufficient players.'
        );
    END IF;

    -- Проверяем, остались ли ещё пользователи в комнате
    IF NOT EXISTS (
        SELECT 1
        FROM users_in_room
        WHERE room_token = p_room_token
    ) THEN
        -- Если комната пуста, удаляем её
        DELETE FROM game_rooms
        WHERE room_token = p_room_token;

        RAISE NOTICE 'Room %s is now empty and has been deleted', p_room_token;

        RETURN json_build_object(
            'status', 'success',
            'message', format('Room %s has been deleted because it is now empty.', p_room_token)
        );
    END IF;

    -- Возвращаем успешный результат
    RETURN json_build_object(
        'status', 'success',
        'message', format('User %s successfully left the room %s', p_login, p_room_token)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION logout_user(p_token TEXT) RETURNS JSON AS $$
DECLARE
    room_check JSON;
    login TEXT; 
BEGIN
    -- Проверяем валидность токена пользователя
    room_check := _is_token_valid(p_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Получаем логин пользователя
    SELECT ut.login
    INTO login
    FROM user_tokens ut
    WHERE ut.token = p_token;

    -- Удаляем токен из таблицы
    DELETE FROM user_tokens 
    WHERE token = p_token;

    -- Возвращаем успешный результат
    RETURN json_build_object(
        'status', 'success',
        'message', format('User %s has been logged out successfully.', login)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_user_avatar(p_token TEXT, p_new_image TEXT) 
RETURNS JSON AS $$
DECLARE
    user_login TEXT;
    room_check JSON;
BEGIN
    -- Проверяем валидность токена
    room_check := _is_token_valid(p_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Получаем логин пользователя из таблицы user_tokens
    SELECT login
    INTO user_login
    FROM user_tokens
    WHERE token = p_token;

    -- Обновляем аватар пользователя в таблице users
    UPDATE users
    SET avatar = p_new_image
    WHERE login = user_login;

    RETURN json_build_object(
            'status', 'success',
            'message', 'Avatar updated successfully'
        );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION make_decision(
    p_user_token TEXT,
    p_room_token TEXT,
    p_word TEXT
) RETURNS JSON AS $$
DECLARE
    user_login TEXT;
    player_id INT;
    decisive_person INT; -- Переименованная переменная
    active_word TEXT;
    person_score INT;
    dany_score INT;
    game_speed TEXT;
    person_threshold INT;
    dany_threshold INT;
    current_phase TEXT;
    game_started BOOLEAN;
    room_check JSON;
    is_time JSON;
    point_awarded_to TEXT;
BEGIN
    -- Проверяем валидность токена
    room_check := _is_token_valid(p_user_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, начата ли игра
    SELECT CASE 
               WHEN phase_name != 'waiting' THEN TRUE 
               ELSE FALSE 
           END
    INTO game_started
    FROM game_rooms
    WHERE room_token = p_room_token;

    IF NOT game_started THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Game has not started yet.'
        );
    END IF;

    -- Проверяем текущую фазу игры
    SELECT phase_name
    INTO current_phase
    FROM game_rooms
    WHERE room_token = p_room_token;

    IF current_phase != 'decision' THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'The current phase is not "decision".'
        );
    END IF;

    -- Проверяем, истекло ли время
    is_time := _is_time_out(p_room_token);
    IF is_time->>'status' = 'success' THEN
        PERFORM __next_round(p_room_token);
        RETURN json_build_object(
            'status', 'success',
            'message', 'Time is up! Proceeding to the next round.'
        );
    END IF;

    -- Получаем логин пользователя
    SELECT login 
    INTO user_login
    FROM user_tokens
    WHERE token = p_user_token;

    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid token or user not found.'
        );
    END IF;

    -- Ищем ID игрока
    SELECT id_player
    INTO player_id
    FROM players
    WHERE login = user_login
      AND room_token = p_room_token;

    IF player_id IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', format('User %s is not a player in room %s.', user_login, p_room_token)
        );
    END IF;

    -- Проверяем, является ли игрок решающим
    SELECT decisive_person_id -- Указываем имя столбца с псевдонимом
    INTO decisive_person
    FROM active_people ap
    WHERE room_token = p_room_token;

    IF player_id != decisive_person THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'You are not the decisive person for this turn.'
        );
    END IF;

    -- Получаем активное слово
    SELECT word 
    INTO active_word
    FROM Words_in_game
    WHERE room_token = p_room_token
      AND status = 'active';

    -- Сохраняем переданное слово в таблицу decided_words
    INSERT INTO decided_words (word, room_token)
    VALUES (p_word, p_room_token)
    ON CONFLICT (room_token) DO UPDATE
    SET word = EXCLUDED.word;

    -- Логика игры: угадано ли слово
    IF p_word = active_word THEN
        UPDATE Game_rooms
        SET person_wins = COALESCE(person_wins, 0) + 1
        WHERE room_token = p_room_token;

        point_awarded_to := 'Persons';
        RAISE NOTICE 'Correct guess! +1 to person_wins.';
    ELSE
        UPDATE Game_rooms
        SET dany_wins = COALESCE(dany_wins, 0) + 1
        WHERE room_token = p_room_token;

        point_awarded_to := 'Dany';
        RAISE NOTICE 'Wrong guess! +1 to dany_wins.';
    END IF;

    -- Получаем текущие очки и режим игры
    SELECT person_wins, dany_wins, COALESCE(speed, 'slow')
    INTO person_score, dany_score, game_speed
    FROM Game_rooms
    WHERE room_token = p_room_token;

    -- Устанавливаем пороговые значения
    IF game_speed = 'fast' THEN
        person_threshold := 8;
        dany_threshold := 4;
    ELSE
        person_threshold := 6;
        dany_threshold := 3;
    END IF;

    -- Проверяем, достиг ли кто-то победного счета
    IF person_score >= person_threshold OR dany_score >= dany_threshold THEN
        IF person_score >= person_threshold THEN
            PERFORM _end_game(p_room_token);
            RETURN json_build_object(
                'status', 'success',
                'message', format('Game ended: Persons team won with %s points!', person_score),
                'last_point_awarded_to', point_awarded_to
            );
        ELSE
            PERFORM _end_game(p_room_token);
            RETURN json_build_object(
                'status', 'success',
                'message', format('Game ended: Dany team won with %s points!', dany_score),
                'last_point_awarded_to', point_awarded_to
            );
        END IF;
    ELSE
        -- Игра продолжается
        PERFORM __next_round(p_room_token);

        RETURN json_build_object(
            'status', 'success',
            'message', format('Game continues: Current scores - Persons: %s, Dany: %s, Mode: %s', person_score, dany_score, game_speed),
            'last_point_awarded_to', point_awarded_to
        );
    END IF;
END;

$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION getLogin(user_token TEXT)
RETURNS JSON AS $$
DECLARE
    user_login TEXT;
BEGIN
    -- Проверяем, существует ли токен в таблице user_tokens
    SELECT login
    INTO user_login
    FROM user_tokens
    WHERE token = user_token;

    -- Если логин не найден, возвращаем сообщение об ошибке
    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid token or user not found.'
        );
    END IF;

    -- Возвращаем успешное сообщение с логином
    RETURN json_build_object(
        'status', 'success',
        'login', user_login
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION send_message(
    p_user_token TEXT,
    p_room_token TEXT,
    p_message TEXT
) RETURNS JSON AS $$

DECLARE
    user_login TEXT;
    active_person_id INT;
    user_person_id INT;
	game_started BOOLEAN;
    room_check JSON;
    max_message_length INT := 500; 
BEGIN
    -- Проверяем валидность токена пользователя
    room_check := _is_token_valid(p_user_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, существует ли комната
    room_check := _is_room_exist(p_room_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, начата ли игра
    SELECT CASE 
               WHEN phase_name != 'waiting' THEN TRUE 
               ELSE FALSE 
           END
    INTO game_started
    FROM game_rooms
    WHERE room_token = p_room_token;

    IF NOT game_started THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Game has not started yet.'
        );
    END IF;

    -- Проверяем, что сообщение не пустое и не слишком длинное
    IF p_message IS NULL OR TRIM(p_message) = '' THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Message cannot be empty.'
        );
    ELSIF LENGTH(p_message) > max_message_length THEN
        RETURN json_build_object(
            'status', 'error',
            'message', format('Message is too long. Maximum length is %s characters.', max_message_length)
        );
    END IF;

    -- Получаем логин пользователя по токену
    SELECT login
    INTO user_login
    FROM user_tokens
    WHERE token = p_user_token;

    -- Проверяем, найден ли логин
    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid token or user not found.'
        );
    END IF;

    -- Получаем ID текущей активной личности
    SELECT a.active_person_id
    INTO active_person_id
    FROM active_people a
    WHERE a.room_token = p_room_token;

    -- Получаем ID игрока для вызывающего
    SELECT p.id_player
    INTO user_person_id
    FROM players p
    WHERE p.login = user_login AND p.room_token = p_room_token;

    -- Проверяем, является ли пользователь активной личностью
    IF user_person_id = active_person_id THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Active persons cannot write messages.'
        );
    END IF;

    -- Добавляем сообщение в таблицу messages
    INSERT INTO messages (login, message, time, room_token)
    VALUES (user_login, p_message, CURRENT_TIMESTAMP, p_room_token);

    -- Возвращаем успешный результат
    RETURN json_build_object(
        'status', 'success',
        'message', format('Message from user %s successfully sent to room %s.', user_login, p_room_token)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION update_card_on_canvas(
    p_user_token TEXT,
    p_room_token TEXT,
    p_image_path TEXT,
    p_x_coordinate INT,
    p_y_coordinate INT,
    p_z_index INT,
    p_back_or_face TEXT,
    p_card_degree INT,
    p_is_on_canvas BOOLEAN
) RETURNS JSON AS $$
DECLARE
    user_login TEXT;
    active_person_id INT;
    user_person_id INT;
    room_check JSON;
    current_phase TEXT;
	game_started BOOLEAN;
    room_status JSON;  -- Variable to store the JSON returned by _is_time_out
BEGIN
    -- Проверяем валидность токена пользователя
    room_check := _is_token_valid(p_user_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, существует ли комната
    room_check := _is_room_exist(p_room_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Проверяем, начата ли игра
    SELECT CASE 
               WHEN phase_name != 'waiting' THEN TRUE 
               ELSE FALSE 
           END
    INTO game_started
    FROM game_rooms
    WHERE room_token = p_room_token;

    IF NOT game_started THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Game has not started yet.'
        );
    END IF;

    -- Проверяем текущую фазу комнаты
    SELECT phase_name
    INTO current_phase
    FROM game_rooms
    WHERE room_token = p_room_token;

    IF current_phase != 'layout' THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'The current phase is not "layout".'
        );
    END IF;

    -- Проверяем, истекло ли время
    room_status := _is_time_out(p_room_token);  -- Store JSON result here
    IF room_status->>'status' = 'success' THEN
        	perform _set_phase(p_room_token, 'discussion');
        RETURN json_build_object(
            'status', 'info',
            'message', 'Time is out. Phase switched.'
        );
    END IF;

    -- Получаем логин пользователя по токену
    SELECT login 
    INTO user_login
    FROM user_tokens
    WHERE token = p_user_token;

    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid token: User not found.'
        );
    END IF;

    -- Получаем ID текущей активной личности
    SELECT ap.active_person_id
    INTO active_person_id
    FROM active_people AS ap
    WHERE ap.room_token = p_room_token;

    IF active_person_id IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'No active person found for the user.'
        );
    END IF;

    -- Получаем ID игрока для вызывающего
    SELECT pl.id_player
    INTO user_person_id
    FROM players AS pl
    WHERE pl.login = user_login;

    -- Проверяем, является ли пользователь активной личностью
    IF user_person_id != active_person_id THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'You are not the active person.'
        );
    END IF;

    -- Обновляем координаты карты в cards_on_canvas
    UPDATE cards_on_canvas AS cc
    SET 
        x_coordinate = p_x_coordinate,
        y_coordinate = p_y_coordinate,
        z_index = p_z_index,
        back_or_face = p_back_or_face,
        card_degree = p_card_degree,
        isoncanvas = p_is_on_canvas
    WHERE cc.id_player = active_person_id
      AND cc.image_path = p_image_path;

    -- Проверяем, было ли обновление успешным
    IF NOT FOUND THEN
        RETURN json_build_object(
            'status', 'error',
            'message', format('Card with image_path %s not found for the active player.', p_image_path)
        );
    END IF;

    -- Возвращаем успешный результат
    RETURN json_build_object(
        'status', 'success',
        'message', format('Card with image_path %s updated successfully on canvas.', p_image_path)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION create_game_room(
    p_token TEXT,
    p_room_name TEXT,
    p_max_amount INT,
    p_speed TEXT
) RETURNS JSON AS $$

DECLARE
    room_token UUID;
    user_login TEXT;
    validation_result JSON;
BEGIN
    -- Проверяем валидность токена
    validation_result := _is_token_valid(p_token);
    IF validation_result->>'status' = 'error' THEN
        RETURN validation_result;
    END IF;

    IF p_max_amount < 3 THEN
		RETURN json_build_object(
            'status', 'error',
            'message', 'Max amount cannot be less than 3.'
      )::JSON;
	END IF;

    -- Проверяем, что название комнаты не пустое и не длиннее 30 символов
    IF p_room_name IS NULL OR LENGTH(p_room_name) = 0 THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Room name cannot be empty.'
        )::JSON;
    ELSIF LENGTH(p_room_name) > 30 THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Room name cannot be longer than 30 characters.'
        )::JSON;
    END IF;

    -- Проверяем значение скорости
    IF p_speed != 'fast' AND p_speed != 'slow' THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid speed parameter. Use "fast" or "slow".'
        )::JSON;
    END IF;

    -- Получаем логин пользователя
    SELECT login INTO user_login
    FROM user_tokens
    WHERE token = p_token;

    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid token: User not found.'
        )::JSON;
    END IF;

    -- Генерируем уникальный токен для комнаты
    room_token := gen_random_uuid();

    -- Создаем запись для новой комнаты
    INSERT INTO game_rooms (
        room_token, 
        phase_name, 
        person_wins, 
        dany_wins, 
        room_name, 
        max_amount, 
        phase_start, 
        creator_login, 
        speed
    ) VALUES (
        room_token,          -- Уникальный токен для комнаты
        'waiting',           -- Начальная фаза
        0,                   -- Очки команды личностей
        0,                   -- Очки Дэни
        p_room_name,         -- Название комнаты
        p_max_amount,        -- Максимальное количество игроков
        NOW(),               -- Время начала
        user_login,          -- Логин создателя комнаты
        p_speed              -- Передаем выбранную скорость
    );

    -- Добавляем создателя комнаты в таблицу users_in_room
    INSERT INTO users_in_room (login, room_token)
    VALUES (user_login, room_token);

    -- Возвращаем успешный результат
    RETURN json_build_object(
    	'status', 'success',
    	'message', 'Game room created successfully.',
    	'room_token', room_token::TEXT
);

END;
$$ LANGUAGE plpgsql;


/*
вывод игры:
1. get_score!
2. get_phase!
3. get_chat
4. get_players!
5. get_words!
6. get_role!
7. get_cards!
8. get_active_and_decisive_person!
*/

CREATE OR REPLACE FUNCTION get_active_games(p_token TEXT)
RETURNS JSON AS $$
DECLARE
    active_games JSON;
	validation_result JSON;
BEGIN
	-- Проверяем валидность токена
    validation_result := _is_token_valid(p_token);
    IF validation_result->>'status' = 'error' THEN
        RETURN validation_result;
    END IF;

    -- Собираем данные об активных играх
    SELECT json_agg(
        json_build_object(
            'room_token', gr.room_token,
            'room_name', gr.room_name,
            'current_amount', (
                SELECT COUNT(*)
                FROM users_in_room uir
                WHERE uir.room_token = gr.room_token
            ),
            'max_amount', gr.max_amount,
            'speed', gr.speed,
            'creator_login', gr.creator_login
        )
    )
    INTO active_games
    FROM game_rooms gr
    WHERE gr.phase_name = 'waiting';

    -- Если нет активных игр, возвращаем пустой массив
    IF active_games IS NULL THEN
        active_games := '[]'::JSON;
    END IF;

    RETURN json_build_object(
            'status', 'success',
            'message', 'Games list',
            'active_games', active_games
        );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION get_game_data(p_user_token TEXT, p_room_token TEXT)
RETURNS JSON AS $$
DECLARE
    user_login TEXT;
    room_check JSON;
    active_person_id INT;
    player_role TEXT;
    v_phase_name TEXT;
    time_check JSON;
    v_phase_start TIMESTAMP;
    v_speed TEXT;
    v_phase_time INTERVAL;
    v_current_time TIMESTAMP;
    v_elapsed_time INTERVAL;
    v_remaining_time INTERVAL;
BEGIN
    -- Извлекаем логин пользователя из таблицы user_tokens
    SELECT login
    INTO user_login
    FROM user_tokens
    WHERE token = p_user_token;

    -- Проверяем, что логин существует
    IF user_login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid user token or login not found.'
        );
    END IF;

    -- Проверяем, существует ли комната
    room_check := _is_room_exist(p_room_token);
    IF room_check->>'status' = 'error' THEN
        RETURN room_check;
    END IF;

    -- Извлекаем данные текущей фазы
    SELECT phase_name, phase_start, speed
    INTO v_phase_name, v_phase_start, v_speed
    FROM game_rooms
    WHERE room_token = p_room_token;

    IF v_phase_name IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Phase not found for the given room token.'
        );
    END IF;

    -- Получаем оставшееся время через функцию check_time
    time_check := _check_time(p_room_token);

    IF time_check->>'status' = 'error' THEN
        RETURN time_check;
    END IF;

    v_remaining_time := (time_check->'data')->>'remaining_time';

    -- Определяем роль пользователя
    SELECT 
        CASE 
            WHEN p.dany_or_person = 'dany' THEN 'dany'
            WHEN p.dany_or_person = 'person' THEN 'person'
            ELSE 'observer'
        END
    INTO player_role
    FROM players p
    WHERE p.room_token = p_room_token AND p.login = user_login;

    -- Извлекаем ID активного игрока
    SELECT ap.active_person_id INTO active_person_id
    FROM active_people ap
    JOIN players p ON ap.active_person_id = p.id_player
    WHERE p.room_token = p_room_token;

    -- Формируем JSON-ответ
RETURN (
    SELECT json_build_object(
        'status', 'success',
        'phase_name', gr.phase_name,
        'remaining_time', v_remaining_time,
        'person_wins', gr.person_wins,
        'dany_wins', gr.dany_wins,
        'players', (
            SELECT array_agg(ur.login)
            FROM users_in_room ur
            WHERE ur.room_token = gr.room_token
        ),
        'ingame_words', (
            SELECT array_agg(w.word)
            FROM words_in_game w
            WHERE w.room_token = gr.room_token 
              AND (w.status = 'ingame' OR w.status = 'active')
        ),
        'active_word', (
            CASE
                WHEN user_login = (
                    SELECT p.login
                    FROM players p
                    WHERE p.id_player = active_person_id
                )
                THEN (
                    SELECT w.word
                    FROM words_in_game w
                    WHERE w.room_token = gr.room_token AND w.status = 'active'
                    LIMIT 1
                )
                ELSE NULL
            END
        ),
        'active_person', (
            SELECT p.login
            FROM active_people ap
            JOIN players p ON ap.active_person_id = p.id_player
            WHERE p.room_token = gr.room_token
            LIMIT 1
        ),
        'decisive_person', (
            SELECT p.login
            FROM active_people ap
            JOIN players p ON ap.decisive_person_id = p.id_player
            WHERE p.room_token = gr.room_token
            LIMIT 1
        ),
        'decided_word', (
            SELECT word FROM decided_words WHERE room_token = p_room_token
        ),
        'player_role', player_role,
        'player_login', user_login,
        'active_cards', (
            SELECT json_agg(
                json_build_object(
                    'card_id', c.card_id,
                    'image_path', c.image_path,
					'x_coordinate', c.x_coordinate,
            		'y_coordinate', c.y_coordinate,
            		'back_or_face', c.back_or_face,
            		'z_index', c.z_index,
            		'card_degree', c.card_degree,
            		'isoncanvas', c.isoncanvas
                )
            )
            FROM cards_on_canvas c
            JOIN players p ON c.id_player = p.id_player
            WHERE p.room_token = gr.room_token
              AND c.id_player = active_person_id
            LIMIT 7
        )
    )
    FROM game_rooms gr
    WHERE gr.room_token = p_room_token
);

END;
$$ LANGUAGE plpgsql;


