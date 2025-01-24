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

