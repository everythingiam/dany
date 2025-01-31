CREATE TABLE Phases ( --есть
	phase_name TEXT PRIMARY KEY,
	phase_time_slow INT NOT NULL,
	phase_time_fast INT NOT NULL
);

INSERT INTO phases (phase_name, phase_time_slow, phase_time_fast)
VALUES 
	('waiting', 86400, 86400),
	('decision', 60, 30),
	('layout', 120, 90),
	('discussion', 60, 30);

CREATE TABLE Memory_cards ( --есть
	image_path TEXT PRIMARY KEY
);

INSERT INTO memory_cards (image_path) VALUES ('1.png'), ('2.png'), ('3.png'), ('4.png'), ('5.png'), ('6.png'), ('7.png'), ('8.png'), ('9.png'), ('10.png'), ('11.png'), ('12.png'), ('13.png'), ('14.png'), ('15.png'), ('16.png'), ('17.png'), ('18.png'), ('19.png'), ('20.png'), ('21.png'), ('22.png'), ('23.png'), ('24.png'), ('25.png'), ('26.png'), ('27.png'), ('28.png'), ('29.png'), ('30.png'), ('31.png'), ('32.png'), ('33.png'), ('34.png'), ('35.png'), ('36.png'), ('37.png'), ('38.png'), ('39.png'), ('40.png'), ('41.png'), ('42.png'), ('43.png'), ('44.png'), ('45.png'), ('46.png'), ('47.png'), ('48.png'), ('49.png'), ('50.png'), ('51.png'), ('52.png'), ('53.png'), ('54.png');

CREATE TABLE users ( --есть
	login TEXT NOT NULL PRIMARY KEY,
	passhash TEXT NOT NULL,
	avatar TEXT NOT NULL DEFAULT 'default.png'
);

CREATE TABLE user_tokens( --есть
  login TEXT NOT NULL,
	token TEXT NOT NULL,
	created_at TIMESTAMP NOT NULL,

	PRIMARY KEY (login, token),
	FOREIGN KEY (login) REFERENCES Users(login) ON DELETE CASCADE
);

CREATE TABLE Game_rooms ( --есть
	room_token TEXT PRIMARY KEY,
	phase_name TEXT NOT NULL,
	person_wins INT NULL,
	dany_wins INT NULL,
	room_name TEXT NOT NULL,
	max_amount INT NOT NULL,
	phase_start TIMESTAMP NOT NULL,
	speed TEXT,
	creator_login TEXT,

	FOREIGN KEY (phase_name) REFERENCES Phases(phase_name) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (creator_login) REFERENCES Users(login) ON DELETE CASCADE
);

CREATE TABLE users_in_room ( --есть
	login TEXT NOT NULL,
	room_token TEXT NOT NULL,

	PRIMARY KEY (login, room_token),
	FOREIGN KEY (login) REFERENCES Users(login) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (room_token) REFERENCES Game_rooms(room_token) ON DELETE CASCADE
);

CREATE TABLE Players ( --есть
	id_player SERIAL PRIMARY KEY,
	login TEXT NOT NULL,
	room_token TEXT NOT NULL,
	dany_or_person TEXT NULL,
	serial_number INT NOT NULL,
	ready BOOLEAN NULL,

	FOREIGN KEY (login) REFERENCES Users(login) ON DELETE CASCADE,
	FOREIGN KEY (room_token) REFERENCES Game_rooms(room_token) ON DELETE CASCADE
);

CREATE TABLE Messages ( --есть
	login TEXT NOT NULL,
	message TEXT NOT NULL,
	room_token TEXT NOT NULL,
	time TIMESTAMP NOT NULL,

	PRIMARY KEY (login, time),
	FOREIGN KEY (login) REFERENCES Users(login) ON DELETE CASCADE,
	FOREIGN KEY (room_token) REFERENCES Game_rooms(room_token) ON DELETE CASCADE
);

CREATE TABLE Decks ( --есть
	room_token TEXT NOT NULL,
	image_path TEXT NOT NULL,
	status TEXT NOT NULL,

	PRIMARY KEY (room_token, image_path),
	FOREIGN KEY (room_token) REFERENCES Game_rooms(room_token) ON DELETE CASCADE,
	FOREIGN KEY (image_path) REFERENCES Memory_cards(image_path) ON DELETE CASCADE
);

CREATE TABLE Active_people ( --есть
	active_person_id INT NOT NULL PRIMARY KEY,
	decisive_person_id INT NOT NULL,
	room_token TEXT NOT NULL,

	FOREIGN KEY (active_person_id) REFERENCES Players(id_player) ON DELETE CASCADE,
	FOREIGN KEY (decisive_person_id) REFERENCES Players(id_player) ON DELETE CASCADE,
	FOREIGN KEY (room_token) REFERENCES Game_rooms(room_token) ON DELETE CASCADE
);

CREATE TABLE Cards_on_canvas ( --есть
	id_player INT NOT NULL,
	image_path TEXT NOT NULL,
	x_coordinate INT NOT NULL,
	y_coordinate INT NOT NULL,
	back_or_face TEXT NOT NULL,
	z_index INT NOT NULL,
	card_degree INT NOT NULL,
	isoncanvas BOOLEAN NOT NULL,
	card_id INT NOT NULL,

	PRIMARY KEY (id_player, image_path),
	FOREIGN KEY (id_player) REFERENCES Active_people(active_person_id) ON DELETE CASCADE,
	FOREIGN KEY (image_path) REFERENCES Memory_cards(image_path) ON DELETE CASCADE
);

CREATE TABLE words_in_game ( --есть
	word TEXT NOT NULL,
	room_token TEXT NOT NULL,
	status TEXT NOT NULL,

	PRIMARY KEY (word, room_token),
	FOREIGN KEY (room_token) REFERENCES Game_rooms(room_token) ON DELETE CASCADE
);

CREATE TABLE words ( --есть
  word TEXT NOT NULL PRIMARY KEY
);

INSERT INTO words (word) VALUES ('решительность'), ('ложь'), ('дэни'), ('природа'), ('рождение'), ('самодельный'), ('веган'), ('бессмертие'), ('цветок'), ('замешательство'), ('скорбь'), ('музыка'), ('удача'), ('одержимость'), ('порок'), ('личность'), ('вселенная'), ('одухотворенность'), ('западный'), ('рассуждение'), ('незавершенный'), ('баланс'), ('надежда'), ('воссоединение'), ('мудрость'), ('маска'), ('роковая женщина'), ('психоанализ'), ('танец'), ('реальность'), ('диск'), ('гонка'), ('исключительный'), ('игра'), ('фантазия'), ('невезение'), ('поражение'), ('художник'), ('чувствительность'), ('бесконечность'), ('жить мечтой'), ('властелин мира'), ('рай'), ('разрушение'), ('сейчас'), ('блаженство'), ('землетрясение');
INSERT INTO words (word) VALUES ('концерт'), ('уединение'), ('тюрьма'), ('убежденность'), ('созидание'), ('голос'), ('центр'), ('океан'), ('религия'), ('утрата себя'), ('поездка'), ('разговор'), ('зоопарк'), ('рождество'), ('дом'), ('застенчивость'), ('дружба'), ('празднование'), ('расставание'), ('набитый живот'), ('клятвы'), ('радуга'), ('погружение'), ('задумчивый'), ('рассеянный'), ('внутренний покой'), ('душа'), ('сожаление'), ('восточный'), ('планета'), ('извержение'), ('соблазнение'), ('против'), ('неразделенная радость'), ('сдаваться'), ('любовь'), ('обязательство'), ('адреналин'), ('осадки'), ('загнанный'), ('восхождение'), ('двойственность'), ('небо'), ('коробка'), ('кино'), ('внеземной'), ('абсурдность');

CREATE TABLE decided_words (
    word TEXT NOT NULL,
    room_token TEXT PRIMARY KEY
);

CREATE TABLE active_word_history (
    id SERIAL PRIMARY KEY,
    room_token TEXT NOT NULL,
    active_word TEXT NOT NULL,
    round_start TIMESTAMP NOT NULL DEFAULT NOW()
);

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


DECLARE
    selected_word VARCHAR;
    current_active_word VARCHAR;
    ingame_words TEXT[];
    remaining_words_count INT;
BEGIN
  
    -- Логика для режима 'next'
    IF p_mode = 'next' THEN
        -- Удаляем старые слова раунда
        DELETE FROM Words_in_game
        WHERE room_token = p_room_token
          AND (status = 'active' OR status = 'ingame');

        -- Проверяем, есть ли достаточно слов
        SELECT COUNT(*) INTO remaining_words_count
        FROM Words_in_game
        WHERE room_token = p_room_token
          AND status = 'empty';
    
        IF remaining_words_count < 5 THEN
            PERFORM _fill_words(p_room_token);
        END IF;
    END IF;

    -- Общая логика для всех режимов
    SELECT ARRAY(
        SELECT word
        FROM Words_in_game
        WHERE room_token = p_room_token
        ORDER BY RANDOM()
        LIMIT 5
    ) INTO ingame_words;

    UPDATE Words_in_game
    SET status = 'ingame'
    WHERE word = ANY(ingame_words)
      AND room_token = p_room_token;

    -- Назначаем новое активное слово
    SELECT word INTO selected_word
    FROM Words_in_game
    WHERE room_token = p_room_token
      AND status = 'ingame'
    LIMIT 1;

    UPDATE Words_in_game
    SET status = 'active'
    WHERE word = selected_word
      AND room_token = p_room_token;

    SELECT word INTO current_active_word
    FROM Words_in_game
    WHERE room_token = p_room_token
      AND status = 'active'
    LIMIT 1;

    -- Если есть текущее активное слово, сохраняем его в историю
    IF current_active_word IS NOT NULL THEN
        INSERT INTO active_word_history (room_token, active_word)
        VALUES (p_room_token, current_active_word);
    END IF;

    RETURN json_build_object(
        'status', 'success',
        'message', 'Active word selected'
    );
END;


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
        'prev_active_word', (
                SELECT active_word
                FROM active_word_history
                WHERE room_token = gr.room_token
                ORDER BY round_start DESC
                LIMIT 1 OFFSET 1  
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


