
-- 1. Создаем таблицы в правильном порядке с учетом зависимостей

-- Таблица университетских зданий (не зависит ни от чего)
CREATE TABLE IF NOT EXISTS university_building (
    number_of_building BIGINT NOT NULL PRIMARY KEY,
    faculty VARCHAR(64) NOT NULL,
    address VARCHAR(64) NOT NULL,
    number_of_floor BIGINT NOT NULL,
    building_condition VARCHAR(64) NOT NULL DEFAULT 'Good'
        CHECK (building_condition IN ('Excellent', 'Good', 'Satisfactory', 'Poor'))
);

-- Таблица персонала (не зависит ни от чего)
CREATE TABLE IF NOT EXISTS staff (
    id_staff BIGINT NOT NULL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    date_of_birth DATE NOT NULL,
    sex VARCHAR(64) NOT NULL,
    address_of_work VARCHAR(64) NOT NULL
);

-- Таблица общежитий (зависит от staff)
CREATE TABLE IF NOT EXISTS dormitory (
    number_of_dormitory BIGINT NOT NULL PRIMARY KEY,
    address VARCHAR(64) NOT NULL,
    number_of_floor BIGINT NOT NULL CHECK (number_of_floor > 0),
    id_of_staff BIGINT NOT NULL REFERENCES staff(id_staff) ON UPDATE CASCADE
);

-- Таблица студентов (зависит от university_building и dormitory)
CREATE TABLE IF NOT EXISTS students (
    id BIGINT NOT NULL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    number_of_building BIGINT NOT NULL REFERENCES university_building(number_of_building) ON UPDATE CASCADE,
    date_of_birth DATE NOT NULL,
    number_of_dormitory BIGINT NOT NULL REFERENCES dormitory(number_of_dormitory) ON UPDATE CASCADE
);

-- Таблица комплектов белья (зависит от students и dormitory)
CREATE TABLE IF NOT EXISTS set_of_liner (
    serial_number BIGINT NOT NULL PRIMARY KEY,
    state VARCHAR(64) NOT NULL DEFAULT 'new'
        CHECK (state IN ('new', 'good', 'used', 'bad')),
    student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
    number_of_dormitory BIGINT NOT NULL REFERENCES dormitory(number_of_dormitory) ON UPDATE CASCADE
);

-- Добавляем обратную ссылку от студентов к комплектам белья
ALTER TABLE students ADD COLUMN liner_serial_number BIGINT UNIQUE 
REFERENCES set_of_liner(serial_number) DEFERRABLE INITIALLY DEFERRED;

-- Промежуточная таблица для студентов и зданий университета
CREATE TABLE IF NOT EXISTS students_university_building (
    id BIGINT NOT NULL PRIMARY KEY,
    students_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    number_of_building BIGINT NOT NULL REFERENCES university_building(number_of_building) ON UPDATE CASCADE,
    UNIQUE (students_id, number_of_building)
);

-- Промежуточная таблица для связи персонала и общежитий
CREATE TABLE IF NOT EXISTS staff_dormitory (
    id BIGINT NOT NULL PRIMARY KEY,
    staff_id BIGINT NOT NULL REFERENCES staff(id_staff) ON DELETE CASCADE,
    dormitory_number BIGINT NOT NULL REFERENCES dormitory(number_of_dormitory) ON UPDATE CASCADE,
    UNIQUE (staff_id, dormitory_number)
);

-- 2. Вставляем данные в правильном порядке

INSERT INTO university_building (number_of_building, faculty, address, number_of_floor, building_condition)
VALUES
(1, 'Mathematics', 'Botanicheskaya st., 25', 5, 'Excellent'),
(2, 'Physics', 'Lenina st., 33', 6, 'Good'),
(3, 'Chemistry', 'Nauki ave., 12', 4, 'Satisfactory'),
(4, 'Biology', 'Akademicheskaya st., 7', 5, 'Excellent'),
(5, 'History', 'Staraya st., 15', 3, 'Good'),
(6, 'Philology', 'Knizhnaya st., 22', 4, 'Excellent'),
(7, 'Economics', 'Denezhnaya st., 41', 6, 'Good'),
(8, 'Law', 'Pravovaya st., 8', 5, 'Excellent'),
(9, 'Medicine', 'Zdorovya st., 3', 7, 'Excellent'),
(10, 'Engineering', 'Tekhnicheskaya st., 19', 6, 'Good'),
(11, 'Architecture', 'Stroiteley st., 11', 4, 'Excellent'),
(12, 'Psychology', 'Dushevnaya st., 5', 3, 'Good'),
(13, 'Sociology', 'Obshchestvennaya st., 9', 4, 'Satisfactory'),
(14, 'Philosophy', 'Mudraya st., 2', 3, 'Good'),
(15, 'Geography', 'Zemnaya st., 14', 5, 'Excellent'),
(16, 'Geology', 'Kamennaya st., 17', 4, 'Good'),
(17, 'Ecology', 'Zelenaya st., 21', 3, 'Excellent'),
(18, 'Computer Science', 'Baytovaya st., 13', 6, 'Excellent'),
(19, 'Foreign Languages', 'Lingvisticheskaya st., 6', 4, 'Good'),
(20, 'Arts', 'Tvorcheskaya st., 10', 3, 'Excellent');

-- Then staff
INSERT INTO staff (id_staff, name, date_of_birth, sex, address_of_work)
VALUES
(1, 'Ivanova Maria Petrovna', '1980-05-15', 'Female', 'Tsentralnaya st., 1'),
(2, 'Petrov Ivan Sergeevich', '1975-08-22', 'Male', 'Shkolnaya st., 5'),
(3, 'Sidorova Olga Viktorovna', '1982-11-30', 'Female', 'Sadovaya st., 12'),
(4, 'Kuznetsov Andrey Dmitrievich', '1978-03-10', 'Male', 'Lesnaya st., 8'),
(5, 'Smirnova Elena Aleksandrovna', '1985-07-18', 'Female', 'Rechnaya st., 3'),
(6, 'Vasiliev Dmitry Igorevich', '1972-09-25', 'Male', 'Gornaya st., 11'),
(7, 'Nikolaeva Tatyana Vladimirovna', '1983-12-05', 'Female', 'Solnechnaya st., 7'),
(8, 'Mikhailov Sergey Anatolievich', '1979-04-20', 'Male', 'Lunnaya st., 9'),
(9, 'Fedorova Anna Pavlovna', '1981-06-14', 'Female', 'Zvezdnaya st., 4'),
(10, 'Alekseev Pavel Olegovich', '1976-10-08', 'Male', 'Parkovaya st., 6'),
(11, 'Dmitrieva Irina Borisovna', '1984-02-28', 'Female', 'Vokzalnaya st., 2'),
(12, 'Sergeev Aleksandr Nikolaevich', '1973-07-12', 'Male', 'Zavodskaya st., 10'),
(13, 'Orlova Natalya Viktorovna', '1986-01-17', 'Female', 'Fabrichnaya st., 13'),
(14, 'Tarasov Viktor Ivanovich', '1971-05-23', 'Male', 'Polevaya st., 15'),
(15, 'Zaitseva Lyudmila Fedorovna', '1987-08-19', 'Female', 'Zheleznodorozhnaya st., 14'),
(16, 'Borisov Artem Sergeevich', '1974-11-11', 'Male', 'Vozdushnaya st., 16'),
(17, 'Kovaleva Svetlana Mikhailovna', '1988-03-07', 'Female', 'Vodnaya st., 17'),
(18, 'Grigoriev Maxim Andreevich', '1970-09-03', 'Male', 'Neftyanaya st., 18'),
(19, 'Sokolova Veronika Denisovna', '1989-12-21', 'Female', 'Ugolnaya st., 19'),
(20, 'Pavlov Artur Romanovich', '1969-04-29', 'Male', 'Atomnaya st., 20');

-- Then dormitory
INSERT INTO dormitory (number_of_dormitory, address, number_of_floor, id_of_staff)
VALUES
(1, 'Studencheskaya st., 1', 5, 1),
(2, 'Molodezhnaya st., 2', 6, 2),
(3, 'Universitetskaya st., 3', 4, 3),
(4, 'Akademicheskaya st., 4', 5, 4),
(5, 'Nauchnaya st., 5', 6, 5),
(6, 'Professorskaya st., 6', 4, 6),
(7, 'Laboratornaya st., 7', 5, 7),
(8, 'Lektsionnaya st., 8', 6, 8),
(9, 'Seminarskaya st., 9', 4, 9),
(10, 'Ekzamenatsionnaya st., 10', 5, 10),
(11, 'Diplomnaya st., 11', 6, 11),
(12, 'Kursovaya st., 12', 4, 12),
(13, 'Zachetnaya st., 13', 5, 13),
(14, 'Sessyonnaya st., 14', 6, 14),
(15, 'Lektorskaya st., 15', 4, 15),
(16, 'Auditornaya st., 16', 5, 16),
(17, 'Bibliotechnaya st., 17', 6, 17),
(18, 'Rektorskaya st., 18', 4, 18),
(19, 'Deanskaya st., 19', 5, 19),
(20, 'Prorektorskaya st., 20', 6, 20);

-- First insert linen sets with NULL student_id (temporarily)
INSERT INTO set_of_liner (serial_number, state, number_of_dormitory, student_id)
VALUES
(1, 'new', 1, NULL),
(2, 'good', 2, NULL),
(3, 'used', 3, NULL),
(4, 'new', 4, NULL),
(5, 'good', 5, NULL),
(6, 'used', 6, NULL),
(7, 'new', 7, NULL),
(8, 'good', 8, NULL),
(9, 'used', 9, NULL),
(10, 'new', 10, NULL),
(11, 'good', 11, NULL),
(12, 'used', 12, NULL),
(13, 'new', 13, NULL),
(14, 'good', 14, NULL),
(15, 'used', 15, NULL),
(16, 'new', 16, NULL),
(17, 'good', 17, NULL),
(18, 'used', 18, NULL),
(19, 'new', 19, NULL),
(20, 'good', 20, NULL);

-- Then students with references to linen sets
INSERT INTO students (id, name, number_of_building, date_of_birth, number_of_dormitory, liner_serial_number)
VALUES
(1, 'Aleksandrov Aleksey Ivanovich', 1, '2000-01-15', 1, 1),
(2, 'Belova Viktoriya Sergeevna', 2, '2001-02-20', 2, 2),
(3, 'Vorobiev Denis Petrovich', 3, '2000-03-25', 3, 3),
(4, 'Grigorieva Anna Dmitrievna', 4, '2001-04-10', 4, 4),
(5, 'Dmitriev Maxim Andreevich', 5, '2000-05-15', 5, 5),
(6, 'Egorova Elena Vladimirovna', 6, '2001-06-20', 6, 6),
(7, 'Zhukov Artem Igorevich', 7, '2000-07-25', 7, 7),
(8, 'Zaitseva Olga Nikolaevna', 8, '2001-08-10', 8, 8),
(9, 'Ivanov Sergey Vasilievich', 9, '2000-09-15', 9, 9),
(10, 'Kovalev Dmitry Aleksandrovich', 10, '2004-10-20', 10, 10),
(11, 'Lebedeva Natalya Petrovna', 11, '2003-11-25', 11, 11),
(12, 'Mironov Andrey Olegovich', 12, '2001-12-10', 12, 12),
(13, 'Nikitina Irina Viktorovna', 13, '2007-01-15', 13, 13),
(14, 'Osipov Pavel Denisovich', 14, '2006-02-20', 14, 14),
(15, 'Petrova Marina Alekseevna', 15, '2008-03-25', 15, 15),
(16, 'Romanov Kirill Sergeevich', 16, '2006-04-10', 16, 16),
(17, 'Semenova Ekaterina Andreevna', 17, '2000-05-15', 17, 17),
(18, 'Tikhonov Artem Vladimirovich', 18, '2005-06-20', 18, 18),
(19, 'Ulyanova Yuliya Dmitrievna', 19, '2004-07-25', 19, 19),
(20, 'Fedorov Ivan Petrovich', 20, '2007-08-10', 20, 20);

-- Now update the linen sets with student IDs
UPDATE set_of_liner SET student_id = 1 WHERE serial_number = 1;
UPDATE set_of_liner SET student_id = 2 WHERE serial_number = 2;
UPDATE set_of_liner SET student_id = 3 WHERE serial_number = 3;
UPDATE set_of_liner SET student_id = 4 WHERE serial_number = 4;
UPDATE set_of_liner SET student_id = 5 WHERE serial_number = 5;
UPDATE set_of_liner SET student_id = 6 WHERE serial_number = 6;
UPDATE set_of_liner SET student_id = 7 WHERE serial_number = 7;
UPDATE set_of_liner SET student_id = 8 WHERE serial_number = 8;
UPDATE set_of_liner SET student_id = 9 WHERE serial_number = 9;
UPDATE set_of_liner SET student_id = 10 WHERE serial_number = 10;
UPDATE set_of_liner SET student_id = 11 WHERE serial_number = 11;
UPDATE set_of_liner SET student_id = 12 WHERE serial_number = 12;
UPDATE set_of_liner SET student_id = 13 WHERE serial_number = 13;
UPDATE set_of_liner SET student_id = 14 WHERE serial_number = 14;
UPDATE set_of_liner SET student_id = 15 WHERE serial_number = 15;
UPDATE set_of_liner SET student_id = 16 WHERE serial_number = 16;
UPDATE set_of_liner SET student_id = 17 WHERE serial_number = 17;
UPDATE set_of_liner SET student_id = 18 WHERE serial_number = 18;
UPDATE set_of_liner SET student_id = 19 WHERE serial_number = 19;
UPDATE set_of_liner SET student_id = 20 WHERE serial_number = 20;

-- Then students_university_building
INSERT INTO students_university_building (id, students_id, number_of_building)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 7, 7),
(8, 8, 8),
(9, 9, 9),
(10, 10, 10),
(11, 11, 11),
(12, 12, 12),
(13, 13, 13),
(14, 14, 14),
(15, 15, 15),
(16, 16, 16),
(17, 17, 17),
(18, 18, 18),
(19, 19, 19),
(20, 20, 20);

-- Then staff_dormitory
INSERT INTO staff_dormitory (id, staff_id, dormitory_number)
VALUES
(1, 1, 1),
(2, 2, 2),
(3, 3, 3),
(4, 4, 4),
(5, 5, 5),
(6, 6, 6),
(7, 7, 7),
(8, 8, 8),
(9, 9, 9),
(10, 10, 10),
(11, 11, 11),
(12, 12, 12),
(13, 13, 13),
(14, 14, 14),
(15, 15, 15),
(16, 16, 16),
(17, 17, 17),
(18, 18, 18),
(19, 19, 19),
(20, 20, 20);



-- 1. Обновление состояния здания университета
UPDATE university_building
SET building_condition = 'Excellent'
WHERE number_of_building = 1;

-- 2. Обновление адреса работы сотрудника
UPDATE staff
SET address_of_work = 'Novaya Ulitsa 10'
WHERE id_staff = 5;

-- 3. Удаление комплектов белья в плохом состоянии (исправленное название)
DELETE FROM set_of_liner
WHERE state = 'bad';