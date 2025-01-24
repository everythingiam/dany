CREATE OR REPLACE FUNCTION _is_token_valid(p_token TEXT)
RETURNS JSON AS $$
DECLARE
    login TEXT;
BEGIN
    -- Проверка существования токена
    SELECT ut.login
    INTO login
    FROM user_tokens ut
    WHERE ut.token = p_token;

    -- Если токен не найден
    IF login IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Invalid token or token not found'
        );
    END IF;

    -- Если токен валиден
    RETURN json_build_object(
        'status', 'success',
        'message', format('Token %s is valid for user %s', p_token, login),
        'data', json_build_object('user', login)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _is_user_valid(p_login TEXT, p_password TEXT)
RETURNS JSON AS $$
DECLARE
    stored_passhash TEXT;
BEGIN
    -- Проверка, существует ли пользователь с таким логином
    SELECT passhash INTO stored_passhash
    FROM users
    WHERE login = p_login;

    -- Если пользователь не найден, выводим сообщение и возвращаем FALSE
    IF stored_passhash IS NULL THEN
        RETURN json_build_object(
          'status', 'error',
          'message', 'User not found'
      );
    END IF;

    -- Сравниваем хеш пароля
    IF stored_passhash = encode(sha256(p_password::BYTEA), 'hex') THEN
        RETURN json_build_object(
          'status', 'success',
          'message', 'User validated'
      );
    ELSE
        RETURN json_build_object(
          'status', 'error',
          'message', 'Invalid password'
      );
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _is_room_exist(p_room_token TEXT)
RETURNS JSON AS $$

DECLARE
    room_count INT;
BEGIN
    -- Проверяем наличие комнаты с указанным токеном
    SELECT COUNT(*)
    INTO room_count
    FROM game_rooms
    WHERE room_token = p_room_token;

    -- Если комната не существует, возвращаем сообщение об ошибке
    IF room_count = 0 THEN
        RETURN json_build_object(
            'status', 'error',
            'message', format('Game room with token %s does not exist.', p_room_token)
        );
    END IF;

    -- Если комната существует, возвращаем сообщение об успехе
    RETURN json_build_object(
        'status', 'success',
        'message', format('Game room with token %s exists.', p_room_token)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _activate_active_cards(p_room_token TEXT)
RETURNS JSON AS $$

DECLARE
    current_active_person_id INT;
    activated_count INT;
    room_check JSON;
BEGIN
    -- Удаление текущих карт из комнаты
    DELETE FROM cards_on_canvas
    WHERE id_player IN (
        SELECT active_person_id
        FROM active_people
        WHERE room_token = p_room_token
    );

	-- Получение ID текущей активной личности
    SELECT active_person_id
    INTO current_active_person_id
    FROM active_people
    WHERE room_token = p_room_token;

    -- Копирование карт из decks в cards_on_canvas с добавлением card_id
	INSERT INTO cards_on_canvas (id_player, image_path, x_coordinate, y_coordinate, back_or_face, z_index, card_degree, isoncanvas, card_id)
	SELECT 
	    current_active_person_id,                              -- ID текущей активной личности
	    d.image_path,                                          -- Путь изображения карты
	    0 AS x_coordinate,                                     -- Начальные координаты x
	    0 AS y_coordinate,                                     -- Начальные координаты y
	    'face' AS back_or_face,                                -- Статус отображения карты
	    0 AS z_index,                                          -- Начальный z-index
	    0 AS card_degree,                                      -- Угол поворота карты
	    FALSE AS isoncanvas,
	    row_number() OVER (ORDER BY d.image_path) AS card_id  -- Генерация последовательных номеров от 1 до 7
		-- Карта не на холсте
	FROM decks d
	WHERE d.room_token = p_room_token
	  AND d.status = 'active'
	LIMIT 7;


    -- Возвращаем сообщение об успехе
    RETURN json_build_object(
        'status', 'success',
        'message', 'Activated 7 cards for layout on canvas.'
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _add_to_players(p_room_token TEXT)
RETURNS JSON AS $$

DECLARE
    inserted_count INT;
BEGIN
    -- Добавляем пользователей из Users_in_room в Players
    INSERT INTO Players (login, room_token, dany_or_person, serial_number, ready)
    SELECT
        login,
        room_token,
        'person' AS dany_or_person,  -- Значение по умолчанию
        row_number() OVER (ORDER BY login) AS serial_number,  -- Порядковый номер игрока
        FALSE AS ready  -- Игроки еще не готовы
    FROM Users_in_room
    WHERE room_token = p_room_token;

    -- Подсчитываем количество добавленных записей
    GET DIAGNOSTICS inserted_count = ROW_COUNT;

    -- Возвращаем сообщение об успешном добавлении
    RETURN json_build_object(
        'status', 'success',
        'message', format('%s users were added to players.', inserted_count)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _check_time(p_token TEXT)
RETURNS JSON AS $$
DECLARE
    v_phase_name TEXT;
    v_phase_start TIMESTAMP;
    v_speed TEXT;
    v_phase_time INTERVAL;
    v_current_time TIMESTAMP;
    v_elapsed_time INTERVAL;
    v_remaining_time INTERVAL;
    phase_check JSON;
    skip_switch_phase BOOLEAN := FALSE; -- Флаг для пропуска switch_phase
BEGIN
    -- Получаем текущую фазу, время начала фазы и скорость из таблицы game_rooms
    SELECT phase_name, phase_start, speed
    INTO v_phase_name, v_phase_start, v_speed
    FROM game_rooms
    WHERE room_token = p_token;

    -- Если фаза не найдена, завершаем выполнение
    IF v_phase_name IS NULL THEN
        RETURN json_build_object(
            'status', 'error',
            'message', 'Phase not found for the given room token.'
        );
    END IF;

    -- Получаем текущее время
    v_current_time := CURRENT_TIMESTAMP;

    -- Вычисляем прошедшее время с начала фазы
    v_elapsed_time := v_current_time - v_phase_start;

    -- Получаем время фазы из таблицы phases в зависимости от скорости
    IF v_speed = 'slow' THEN
        SELECT phase_time_slow
        INTO v_phase_time
        FROM phases
        WHERE phase_name = v_phase_name;
    ELSIF v_speed = 'fast' THEN
        SELECT phase_time_fast
        INTO v_phase_time
        FROM phases
        WHERE phase_name = v_phase_name;
    ELSE
        RETURN json_build_object(
            'status', 'error',
            'message', format('Invalid speed: %s', v_speed)
        );
    END IF;

    -- Вычисляем оставшееся время до конца фазы
    v_remaining_time := v_phase_time - v_elapsed_time;

    -- Если прошедшее время больше или равно времени фазы, активируем следующую фазу
    IF v_elapsed_time >= v_phase_time THEN
        -- Если текущая фаза 'decision', вызываем _make_wrong_decision
        IF v_phase_name = 'decision' THEN
            phase_check := _make_wrong_decision(p_token, 'babushka');
            IF phase_check->>'status' = 'error' THEN
                RETURN phase_check;
            END IF;

            -- Устанавливаем флаг, чтобы пропустить switch_phase
            skip_switch_phase := TRUE;
        END IF;

        -- Выполняем switch_phase только если skip_switch_phase = FALSE
        IF NOT skip_switch_phase THEN
            PERFORM _switch_phase(p_token);
        END IF;

        -- Повторно получаем новую фазу, время начала и скорость
        SELECT phase_name, phase_start, speed
        INTO v_phase_name, v_phase_start, v_speed
        FROM game_rooms
        WHERE room_token = p_token;

        -- Обновляем текущее время
        v_current_time := CURRENT_TIMESTAMP;

        -- Получаем время новой фазы
        IF v_speed = 'slow' THEN
            SELECT phase_time_slow
            INTO v_phase_time
            FROM phases
            WHERE phase_name = v_phase_name;
        ELSIF v_speed = 'fast' THEN
            SELECT phase_time_fast
            INTO v_phase_time
            FROM phases
            WHERE phase_name = v_phase_name;
        ELSE
            RETURN json_build_object(
                'status', 'error',
                'message', format('Invalid speed for new phase: %s', v_speed)
            );
        END IF;

        -- Возвращаем уведомление о переключении фазы с полным временем новой фазы
        RETURN json_build_object(
            'status', 'success',
            'data', json_build_object(
                'remaining_time', v_phase_time
            ),
            'message', format('Phase %s completed. Switched to next phase: %s with full time: %s.', v_phase_name, v_phase_name, v_phase_time)
        );
    END IF;

    -- Возвращаем оставшееся время до конца текущей фазы
    RETURN json_build_object(
        'status', 'success',
        'data', json_build_object(
            'remaining_time', v_remaining_time
        ),
        'message', format('Time remaining for phase %s: %s', v_phase_name, v_remaining_time)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _end_game(p_room_token TEXT)
RETURNS JSON AS $$
DECLARE
    actions JSON := '[]'::JSON;
BEGIN
    -- Удаляем карты с игрового холста
    DELETE FROM cards_on_canvas
    WHERE id_player IN (
        SELECT id_player FROM Players WHERE room_token = p_room_token
    );

    -- Удаляем всех участников из комнаты
    DELETE FROM Users_in_room
    WHERE login IN (
        SELECT login FROM Players WHERE room_token = p_room_token
    )
    AND room_token = p_room_token;

    -- Удаляем активных игроков
    DELETE FROM Active_people
    WHERE active_person_id IN (
        SELECT active_person_id FROM Players WHERE room_token = p_room_token
    );

    -- Очищаем слова, связанные с комнатой
    DELETE FROM Words_in_game
    WHERE room_token = p_room_token;

    -- Удаляем игроков
    DELETE FROM Players
    WHERE room_token = p_room_token;

    -- Удаляем карты из decks
    DELETE FROM decks
    WHERE room_token = p_room_token;

    -- Удаляем комнату
    DELETE FROM game_rooms
    WHERE room_token = p_room_token;

    DELETE FROM decided_words
    WHERE room_token = p_room_token;

    -- Возвращаем сообщение об успехе с действиями
    RETURN json_build_object(
        'status', 'success',
        'message', 'Game successfully ended.'
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _fill_cards(p_room_token TEXT)
RETURNS JSON AS $$
DECLARE
    inserted_count INT;
BEGIN
    -- Добавляем карты в decks
    INSERT INTO decks (room_token, image_path, status)
    SELECT p_room_token, image_path, 'empty'
    FROM memory_cards
    ORDER BY RANDOM();

    -- Подсчитываем количество добавленных карт
    GET DIAGNOSTICS inserted_count = ROW_COUNT;

    -- Возвращаем сообщение об успешном заполнении
    RETURN json_build_object(
        'status', 'success',
        'message', format('%s cards were added to decks.', inserted_count)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _fill_words(p_room_token TEXT)
RETURNS JSON AS $$
DECLARE
    inserted_count INT;
BEGIN
    -- Добавляем слова в Words_in_game
    INSERT INTO Words_in_game (word, room_token, status)
    SELECT word, p_room_token, 'empty'
    FROM Words
    ORDER BY RANDOM();

    -- Подсчитываем количество добавленных слов
    GET DIAGNOSTICS inserted_count = ROW_COUNT;

    -- Возвращаем сообщение об успешном заполнении
    RETURN json_build_object(
        'status', 'success',
        'message', format('%s words were added to words_in_game.', inserted_count)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _make_wrong_decision(p_room_token TEXT, p_word TEXT)
RETURNS JSON AS $$
DECLARE
    active_word TEXT;
    person_score INT;
    dany_score INT;
    game_speed TEXT;
    person_threshold INT;
    dany_threshold INT;
    current_phase TEXT;
    room_check JSON;
    is_time BOOLEAN;
    last_action TEXT;
BEGIN
    -- Получаем активное слово
    SELECT word 
    INTO active_word
    FROM Words_in_game
    WHERE room_token = p_room_token
      AND status = 'active';

    -- Логика игры: угадано ли слово
    IF p_word = active_word THEN
        UPDATE Game_rooms
        SET person_wins = COALESCE(person_wins, 0) + 1
        WHERE room_token = p_room_token;

        last_action := 'Person team scored +1 point.';
        RAISE NOTICE 'Correct guess! +1 to person_wins.';
    ELSE
        -- Если слово не угадано, вставляем 'missed' в decided_words
        INSERT INTO decided_words (word, room_token)
        VALUES ('missed', p_room_token)
        ON CONFLICT (room_token) DO UPDATE
        SET word = 'missed';

        UPDATE Game_rooms
        SET dany_wins = COALESCE(dany_wins, 0) + 1
        WHERE room_token = p_room_token;

        last_action := 'Dany team scored +1 point.';
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
                'data', json_build_object(
                	'last_action', last_action,
                	'winner', 'Dany team'
				)
            );
        ELSE
            PERFORM _end_game(p_room_token);
            RETURN json_build_object(
                'status', 'success',
                'message', format('Game ended: Dany team won with %s points!', dany_score),
				'data', json_build_object(
                	'last_action', last_action,
                	'winner', 'Dany team'
				)
            );
        END IF;
    ELSE
        -- Игра продолжается
        PERFORM __next_round(p_room_token);
        RETURN json_build_object(
            'status', 'success',
            'message', format('Game continues: Current scores - Persons: %s, Dany: %s', person_score, dany_score),
            'data', json_build_object(
                	'last_action', last_action
			)
        );
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _pick_active_cards(p_room_token TEXT, p_mode TEXT)
RETURNS JSON AS $$
DECLARE
    active_cards TEXT[];
    remaining_cards_count INT;
BEGIN
    IF p_mode = 'next' THEN
        -- Удаляем карты со статусом 'active'
        DELETE FROM decks
        WHERE room_token = p_room_token
          AND status = 'active';
        
        -- Проверяем, осталось ли достаточно карт
        SELECT COUNT(*) INTO remaining_cards_count
        FROM decks
        WHERE room_token = p_room_token;
        
        IF remaining_cards_count < 7 THEN
            PERFORM _fill_cards(p_room_token);
        END IF;
    END IF;

    -- Получаем 7 случайных карт
    SELECT ARRAY(
        SELECT image_path
        FROM decks
        WHERE room_token = p_room_token
        ORDER BY RANDOM()
        LIMIT 7
    ) INTO active_cards;

    -- Обновляем статус карт на 'active'
    UPDATE decks
    SET status = 'active'
    WHERE image_path = ANY(active_cards)
      AND room_token = p_room_token;

    -- Возвращаем успешный результат
    RETURN json_build_object(
        'status', 'success',
        'message', '7 active cards have been assigned to the active person: ' || array_to_string(active_cards, ', ')
    );
    
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _pick_active_person(
    p_room_token TEXT, 
    p_mode TEXT
) RETURNS JSON AS $$
DECLARE
    current_active_person_id INT;
    next_active_person_id INT;
    decisive_person_id INT;
BEGIN
    IF p_mode = 'start' THEN
        -- Логика для начала игры
        SELECT id_player 
        INTO current_active_person_id
        FROM players
        WHERE room_token = p_room_token
        ORDER BY serial_number
        LIMIT 1;

        -- Проверяем, найден ли игрок
        IF current_active_person_id IS NULL THEN
            RETURN json_build_object(
                'status', 'error',
                'message', 'No players found in room'
            );
        END IF;

        -- Вставляем активного игрока в таблицу active_people
        INSERT INTO active_people (active_person_id, decisive_person_id, room_token)
        VALUES (
            current_active_person_id,
            (SELECT id_player
             FROM players
             WHERE room_token = p_room_token
               AND id_player > current_active_person_id
             ORDER BY id_player
             LIMIT 1), -- Следующий игрок по порядку
            p_room_token
        );

        -- Возвращаем успешное сообщение с ID активного игрока
        RETURN json_build_object(
            'status', 'success',
            'message', 'Game started',
            'current_active_player_id', current_active_person_id
        );

    ELSIF p_mode = 'next' THEN
        -- Логика для следующего раунда
        -- Удаление текущего активного игрока
        SELECT active_person_id 
        INTO current_active_person_id
        FROM active_people
        WHERE room_token = p_room_token;

        DELETE FROM active_people
        WHERE active_person_id = current_active_person_id;

        -- Поиск следующего активного игрока
        LOOP
            SELECT id_player 
            INTO next_active_person_id
            FROM players
            WHERE room_token = p_room_token
              AND id_player > current_active_person_id
            ORDER BY id_player
            LIMIT 1;

            -- Если достигнут конец списка, возвращаемся к первому игроку
            IF next_active_person_id IS NULL THEN
                SELECT id_player 
                INTO next_active_person_id
                FROM players
                WHERE room_token = p_room_token
                ORDER BY id_player
                LIMIT 1;
            END IF;

            -- Проверяем, находится ли игрок в комнате
            IF EXISTS (
                SELECT 1 
                FROM users_in_room 
                WHERE login = (SELECT login FROM players WHERE id_player = next_active_person_id)
            ) THEN
                EXIT; -- Игрок найден
            END IF;

            -- Если игрока нет в комнате, пропускаем его
            current_active_person_id := next_active_person_id;
        END LOOP;

        -- Устанавливаем решающего игрока
        SELECT id_player 
        INTO decisive_person_id
        FROM players
        WHERE room_token = p_room_token
          AND id_player > next_active_person_id
        ORDER BY id_player
        LIMIT 1;

        -- Если конец списка, берем первого игрока
        IF decisive_person_id IS NULL THEN
            SELECT id_player 
            INTO decisive_person_id
            FROM players
            WHERE room_token = p_room_token
            ORDER BY id_player
            LIMIT 1;
        END IF;

        -- Добавляем следующего активного игрока и решающего игрока
        INSERT INTO active_people (active_person_id, decisive_person_id, room_token)
        VALUES (next_active_person_id, decisive_person_id, p_room_token);

        -- Возвращаем успешное сообщение с ID активного и решающего игроков
        RETURN json_build_object(
            'status', 'success',
            'message', 'Active person role passed and decisive person set',
            'active_player_id', next_active_person_id,
            'decisive_player_id', decisive_person_id
        );
    END IF;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _pick_active_words(
    p_room_token TEXT, 
    p_mode TEXT
) RETURNS JSON AS $$
DECLARE
    selected_word VARCHAR;
    ingame_words TEXT[];
    remaining_words_count INT;
BEGIN
    IF p_mode = 'next' THEN
        -- Удаляем предыдущие слова раунда
        DELETE FROM Words_in_game
        WHERE room_token = p_room_token
          AND (status = 'active' OR status = 'ingame');
    
        -- Проверяем, есть ли достаточно слов
        SELECT COUNT(*) INTO remaining_words_count
        FROM Words_in_game
        WHERE room_token = p_room_token
          AND status = 'empty';
    
        IF remaining_words_count < 5 THEN
            -- Заполняем недостаток слов
            PERFORM _fill_words(p_room_token);
        END IF;
    END IF;

    -- Рандомно выбираем 5 слов для статуса 'ingame'
    SELECT ARRAY(
           SELECT word
           FROM Words_in_game
           WHERE room_token = p_room_token
           ORDER BY RANDOM()
           LIMIT 5
       ) INTO ingame_words;

    -- Обновляем статус слов на 'ingame'
    UPDATE Words_in_game
    SET status = 'ingame'
    WHERE word = ANY(ingame_words)
      AND room_token = p_room_token;

    -- Назначаем одно слово активным (status = 'active')
    SELECT word INTO selected_word
    FROM Words_in_game
    WHERE room_token = p_room_token
      AND status = 'ingame'
    LIMIT 1;

    UPDATE Words_in_game
    SET status = 'active'
    WHERE word = selected_word
      AND room_token = p_room_token;

    -- Возвращаем успешное сообщение с активным словом и списком ин-игровых слов
    RETURN json_build_object(
        'status', 'success',
        'message', 'Active word selected'
    );

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _pick_dany(
    p_room_token TEXT
) RETURNS JSON AS $$

DECLARE
    dany_id INT;
BEGIN
    -- Рандомно выбираем игрока для роли Дани
    SELECT id_player INTO dany_id
    FROM Players
    WHERE room_token = p_room_token
    ORDER BY RANDOM()
    LIMIT 1;

    -- Обновляем роль игрока
    UPDATE Players
    SET dany_or_person = 'dany'
    WHERE id_player = dany_id;

    -- Возвращаем успешное сообщение с ID выбранного игрока
    RETURN json_build_object(
        'status', 'success',
        'message', 'Player has been randomly selected as Dany'
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _set_phase(
    p_room_token TEXT,
    p_phase TEXT
) RETURNS JSON AS $$

BEGIN
    -- Устанавливаем фазу в таблице game_rooms
    UPDATE game_rooms
    SET phase_name = p_phase, phase_start = CURRENT_TIMESTAMP
    WHERE room_token = p_room_token;

    -- Возвращаем успешное сообщение о смене фазы
    RETURN json_build_object(
        'status', 'success',
        'message', format('Phase set to "%s"', p_phase)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _switch_phase(
    p_token TEXT
) RETURNS JSON AS $$

DECLARE
    v_current_phase TEXT;
BEGIN
    -- Получаем текущую фазу игры
    SELECT phase_name
    INTO v_current_phase
    FROM game_rooms
    WHERE room_token = p_token;

    -- Определяем следующую фазу в зависимости от текущей фазы
    CASE v_current_phase
        WHEN 'waiting' THEN
            UPDATE game_rooms
            SET phase_name = 'layout', phase_start = CURRENT_TIMESTAMP
            WHERE room_token = p_token;
            RETURN json_build_object(
                'status', 'success',
                'message', 'Switched phase to layout'
            );
        WHEN 'layout' THEN
            UPDATE game_rooms
            SET phase_name = 'discussion', phase_start = CURRENT_TIMESTAMP
            WHERE room_token = p_token;
            RETURN json_build_object(
                'status', 'success',
                'message', 'Switched phase to discussion'
            );
        WHEN 'discussion' THEN
            UPDATE game_rooms
            SET phase_name = 'decision', phase_start = CURRENT_TIMESTAMP
            WHERE room_token = p_token;
            RETURN json_build_object(
                'status', 'success',
                'message', 'Switched phase to decision'
            );
        WHEN 'decision' THEN
            UPDATE game_rooms
            SET phase_name = 'layout', phase_start = CURRENT_TIMESTAMP
            WHERE room_token = p_token;
            RETURN json_build_object(
                'status', 'success',
                'message', 'Switched phase to layout'
            );
        ELSE
            RAISE EXCEPTION 'Invalid phase: %', v_current_phase;
    END CASE;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION __next_round(p_token TEXT)
RETURNS JSON AS $$
DECLARE
    room_check JSON;
    actions JSON := '[]'::JSON;
BEGIN
    PERFORM _pick_active_person(p_token, 'next');

    PERFORM _pick_active_words(p_token, 'next');

    PERFORM _pick_active_cards(p_token, 'next');

    PERFORM _activate_active_cards(p_token);

    PERFORM _set_phase(p_token, 'layout');

    RETURN json_build_object(
        'status', 'success',
        'message', 'Next round initialized successfully.'
    )::JSON;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION __start_game(p_token TEXT) RETURNS JSON AS $$
DECLARE
    room_check JSON;
    actions JSONB := '[]'::JSONB; -- Изменено на JSONB
BEGIN
    PERFORM _add_to_players(p_token);

    PERFORM _pick_active_person(p_token, 'start');

    PERFORM _pick_dany(p_token);

    PERFORM _fill_words(p_token);

    PERFORM _pick_active_words(p_token, 'start');

    PERFORM _fill_cards(p_token);

    PERFORM _pick_active_cards(p_token, 'start');

    PERFORM _set_phase(p_token, 'layout');

    PERFORM _activate_active_cards(p_token);

    RETURN json_build_object(
        'status', 'success',
        'message', 'Game has started successfully'
        -- 'data', json_build_object('actions', actions)
    );
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION _is_time_out(p_token TEXT)
RETURNS JSON AS $$

DECLARE
    v_phase_name TEXT;
    v_phase_start TIMESTAMP;
    v_speed TEXT;
    v_phase_time INTERVAL;
    v_current_time TIMESTAMP;
    v_elapsed_time INTERVAL;
    v_remaining_time INTERVAL;
BEGIN
    -- Получаем текущую фазу, время начала фазы и скорость из таблицы game_rooms
    SELECT phase_name, phase_start, speed
    INTO v_phase_name, v_phase_start, v_speed
    FROM game_rooms
    WHERE room_token = p_token;

    -- Получаем текущее время
    v_current_time := CURRENT_TIMESTAMP;

    -- Вычисляем прошедшее время с начала фазы
    v_elapsed_time := v_current_time - v_phase_start;

    -- Получаем время фазы из таблицы phases в зависимости от скорости
    IF v_speed = 'slow' THEN
        SELECT phase_time_slow
        INTO v_phase_time
        FROM phases
        WHERE phase_name = v_phase_name;
    ELSIF v_speed = 'fast' THEN
        SELECT phase_time_fast
        INTO v_phase_time
        FROM phases
        WHERE phase_name = v_phase_name;
    ELSE
        RETURN json_build_object(
            'status', 'error',
            'message', format('Invalid speed: %s', v_speed)
        );
    END IF;

    -- Вычисляем оставшееся время до конца фазы
    v_remaining_time := v_phase_time - v_elapsed_time;

    -- Если прошедшее время больше или равно времени фазы, активируем следующий раунд и возвращаем сообщение
    IF v_elapsed_time >= v_phase_time THEN
        RETURN json_build_object(
            'status', 'success',
            'message', 'Phase time expired, next round can start.'
        );
    END IF;

    -- Логируем оставшееся время
    RETURN json_build_object(
        'status', 'info',
        'message', format('Time remaining for phase %s: %s', v_phase_name, v_remaining_time)
    );
END;
$$ LANGUAGE plpgsql;
