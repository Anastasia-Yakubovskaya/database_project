
-- 1. Создаем таблицы 
CREATE TABLE IF NOT EXISTS university_building (
    number_of_building BIGINT NOT NULL PRIMARY KEY,
    faculty VARCHAR(64) NOT NULL,
    address VARCHAR(64) NOT NULL,
    number_of_floor BIGINT NOT NULL,
    building_condition VARCHAR(64) NOT NULL 
);

CREATE TABLE IF NOT EXISTS staff (
    id_staff BIGINT NOT NULL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    date_of_birth DATE NOT NULL,
    sex VARCHAR(64) NOT NULL,
    address_of_work VARCHAR(64) NOT NULL
);

CREATE TABLE IF NOT EXISTS dormitory (
    number_of_dormitory BIGINT NOT NULL PRIMARY KEY,
    address VARCHAR(64) NOT NULL,
    number_of_floor BIGINT NOT NULL CHECK (number_of_floor > 0),
    id_of_staff BIGINT NOT NULL REFERENCES staff(id_staff) ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS students (
    id BIGINT NOT NULL PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    number_of_building BIGINT NOT NULL REFERENCES university_building(number_of_building) ON UPDATE CASCADE,
    date_of_birth DATE NOT NULL,
    number_of_dormitory BIGINT NOT NULL REFERENCES dormitory(number_of_dormitory) ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS set_of_liner (
    serial_number BIGINT NOT NULL PRIMARY KEY,
    state VARCHAR(64) NOT NULL DEFAULT 'new'
        CHECK (state IN ('new', 'good', 'used', 'bad')),
    student_id BIGINT REFERENCES students(id) ON DELETE CASCADE,
    number_of_dormitory BIGINT NOT NULL REFERENCES dormitory(number_of_dormitory) ON UPDATE CASCADE
);

ALTER TABLE students ADD COLUMN liner_serial_number BIGINT UNIQUE 
REFERENCES set_of_liner(serial_number) DEFERRABLE INITIALLY DEFERRED;


CREATE TABLE IF NOT EXISTS students_university_building (
    id BIGINT NOT NULL PRIMARY KEY,
    students_id BIGINT NOT NULL REFERENCES students(id) ON DELETE CASCADE,
    number_of_building BIGINT NOT NULL REFERENCES university_building(number_of_building) ON UPDATE CASCADE,
    UNIQUE (students_id, number_of_building)
);


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

-- 1. Создание временной таблицы для зданий в плохом состоянии
CREATE TEMP TABLE IF NOT EXISTS bad_condition AS
SELECT * FROM university_building
WHERE building_condition = 'Poor';

SELECT * FROM bad_condition;

-- 2. Создание временной таблицы с количеством зданий в плохом состоянии
CREATE TEMP TABLE IF NOT EXISTS bad_condition_summary AS 
SELECT  
    number_of_building,  
    COUNT(*) AS bad_buildings_count  
FROM university_building  
WHERE building_condition = 'Poor'  
GROUP BY number_of_building;  

SELECT * FROM bad_condition_summary LIMIT 5;

-- 3. Анализ студентов по году рождения (WITH запрос)
WITH students_by_year AS (
    SELECT
        EXTRACT(YEAR FROM date_of_birth) AS birth_year,
        COUNT(*) AS students_count
    FROM students
    GROUP BY birth_year
)

SELECT * FROM students_by_year
ORDER BY birth_year;

-- 4. Создание представления для студентов, родившихся до 2006 года
CREATE OR REPLACE VIEW students_before_2006 AS
SELECT id, name, date_of_birth, number_of_dormitory
FROM students
WHERE EXTRACT(YEAR FROM date_of_birth) < 2006;


SELECT * FROM students_before_2006;


-- 1. Создание материализованного представления для общежитий выше 5 этажей
CREATE MATERIALIZED VIEW dormitory_higher_5floor AS
SELECT number_of_dormitory, number_of_floor, id_of_staff
FROM dormitory
WHERE number_of_floor > 5;

SELECT * FROM dormitory_higher_5floor;

-- 2. Создание индекса для поиска по имени студента и анализ запроса

SELECT * FROM students WHERE name = 'Ivanov Ivan Ivanovich';
EXPLAIN ANALYZE SELECT * FROM students WHERE name = 'Ivanov Ivan Ivanovich';

CREATE INDEX IF NOT EXISTS idx_students_name ON students(name);

-- 3. Генерация случайных студентов с реалистичными именами

WITH first_names AS (
    SELECT unnest(ARRAY[
        'Ivan', 'Alexander', 'Sergey', 'Dmitry', 'Andrey', 
        'Anna', 'Maria', 'Elena', 'Olga', 'Natalia'
    ]) AS first_name
),
last_names AS (
    SELECT unnest(ARRAY[
        'Ivanov', 'Petrov', 'Sidorov', 'Smirnov', 'Kuznetsov',
        'Volkov', 'Fedorov', 'Morozov', 'Nikolaev', 'Pavlov'
    ]) AS last_name
),
middle_names AS (
    SELECT unnest(ARRAY[
        'Ivanovich', 'Petrovich', 'Sergeevich', 'Dmitrievich', 'Andreevich',
        'Ivanovna', 'Petrovna', 'Sergeevna', 'Dmitrievna', 'Andreevna'
    ]) AS middle_name
),
building_numbers AS (
    SELECT number_of_building FROM university_building
),
dormitory_numbers AS (
    SELECT number_of_dormitory FROM dormitory
),
random_names AS (
    SELECT 
        'Student_' || g AS id_alias,
        (SELECT last_name FROM last_names ORDER BY random() LIMIT 1) || ' ' ||
        (SELECT first_name FROM first_names ORDER BY random() LIMIT 1) || ' ' ||
        (SELECT middle_name FROM middle_names ORDER BY random() LIMIT 1) AS full_name,
        ('2000-01-01'::date + (g % 365) * interval '1 day') AS birth_date,
        (SELECT number_of_building FROM building_numbers ORDER BY random() LIMIT 1) AS building_num,
        (SELECT number_of_dormitory FROM dormitory_numbers ORDER BY random() LIMIT 1) AS dormitory_num
    FROM generate_series(40, 10000) AS g
)


INSERT INTO students (id, name, number_of_building, date_of_birth, number_of_dormitory)
SELECT 
    row_number() OVER () + (SELECT COALESCE(MAX(id), 0) FROM students),  -- Продолжаем нумерацию
    full_name,
    building_num,
    birth_date,
    dormitory_num
FROM random_names;

-- Обновляем комплекты белья для новых студентов
WITH new_students AS (
    SELECT id FROM students WHERE liner_serial_number IS NULL ORDER BY id
),
available_liners AS (
    SELECT serial_number FROM set_of_liner WHERE student_id IS NULL ORDER BY random()
),
matched_liners AS (
    SELECT 
        ns.id AS student_id,
        al.serial_number AS liner_serial
    FROM new_students ns
    JOIN available_liners al ON true
    WHERE NOT EXISTS (
        SELECT 1 FROM set_of_liner sl 
        WHERE sl.serial_number = al.serial_number AND sl.student_id IS NOT NULL
    )
    LIMIT (SELECT COUNT(*) FROM new_students)
)
UPDATE students s
SET liner_serial_number = ml.liner_serial
FROM matched_liners ml
WHERE s.id = ml.student_id;

-- Обновляем связь в таблице set_of_liner
UPDATE set_of_liner sl
SET student_id = s.id
FROM students s
WHERE sl.serial_number = s.liner_serial_number AND sl.student_id IS NULL;

-- Анализ запроса с использованием индекса
EXPLAIN ANALYZE SELECT * FROM students WHERE name = 'Ivanov Ivan Ivanovich';

-- Анализ производительности обновления комплектов белья (исправленное название)
EXPLAIN ANALYZE 
UPDATE set_of_liner 
SET number_of_dormitory = number_of_dormitory + 1 
WHERE serial_number < 10;

--  Анализ производительности запроса поиска мужского персонала
EXPLAIN ANALYZE 
SELECT * FROM staff 
WHERE sex = 'Male';

--  Анализ производительности вставки нового общежития
EXPLAIN ANALYZE 
INSERT INTO dormitory 
VALUES (21, 'Gornaya_11', 6, 21);

-- Создание B-tree индекса 
CREATE INDEX IF NOT EXISTS idx_students_dormitory_dob_name ON students USING btree (date_of_birth);

EXPLAIN ANALYZE
SELECT * FROM students WHERE date_of_birth = '2004-04-04';

-- 3. Создание BRIN индекса
CREATE INDEX IF NOT EXISTS idx_students_dormitory_brin ON students USING brin(date_of_birth);

EXPLAIN ANALYZE
SELECT * FROM students WHERE date_of_birth = '2004-04-04';

-- 4. Создание HASH индекса
CREATE INDEX IF NOT EXISTS idx_students_dormitory_hash ON students USING hash(date_of_birth);

EXPLAIN ANALYZE
SELECT * FROM students WHERE date_of_birth = '2004-04-04';

--Триггер
CREATE OR REPLACE FUNCTION check_student_age()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.date_of_birth IS NULL THEN
        RAISE EXCEPTION 'Date of birth cannot be NULL';
    END IF;
    
    IF NEW.date_of_birth > CURRENT_DATE THEN
        RAISE EXCEPTION 'Date of birth cannot be in the future';
    END IF;
    
    IF EXTRACT(YEAR FROM AGE(NEW.date_of_birth)) < 16 THEN
        RAISE EXCEPTION 'Student must be at least 16 years old';
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_students_age_check
BEFORE INSERT OR UPDATE ON students
FOR EACH ROW
EXECUTE FUNCTION check_student_age();

--Транзакция
BEGIN;

-- Проверка доступности комплектов
DO $$
DECLARE
    cnt INTEGER;
BEGIN
    SELECT COUNT(*) INTO cnt 
    FROM set_of_liner 
    WHERE number_of_dormitory = 3 AND student_id IS NULL;
    
    IF cnt = 0 THEN
        RAISE EXCEPTION 'No available sets in dormitory 3';
    END IF;
END $$;

UPDATE students SET number_of_dormitory = 3 WHERE id = 5;

UPDATE set_of_liner SET student_id = 5 
WHERE serial_number = (
    SELECT serial_number 
    FROM set_of_liner 
    WHERE number_of_dormitory = 3 AND student_id IS NULL 
    LIMIT 1
);

COMMIT;

-- Функция для равномерного распределения студентов по общежитиям
CREATE OR REPLACE FUNCTION raspredelit_studentov()
RETURNS TEXT AS $$
DECLARE
    vsego_studentov INT;
    vsego_obshejitiy INT; 
    na_odno_obshejitie INT; 
    ostalos_lishnih INT; 
    obshejitie RECORD;    
    schetchik INT := 0;   
BEGIN

    SELECT COUNT(*) INTO vsego_studentov FROM students;
    SELECT COUNT(*) INTO vsego_obshejitiy FROM dormitory;
    
    na_odno_obshejitie := vsego_studentov / vsego_obshejitiy;
    ostalos_lishnih := vsego_studentov % vsego_obshejitiy;
    
    CREATE TEMP TABLE raspredelenie AS
    SELECT number_of_dormitory, 
           na_odno_obshejitie + 
           CASE WHEN ROW_NUMBER() OVER () <= ostalos_lishnih THEN 1 ELSE 0 END AS nado_studentov
    FROM dormitory
    ORDER BY number_of_dormitory;
    
    FOR obshejitie IN SELECT * FROM raspredelenie ORDER BY number_of_dormitory
    LOOP
        UPDATE students
        SET number_of_dormitory = obshejitie.number_of_dormitory
        WHERE id IN (
            SELECT id 
            FROM students
            WHERE number_of_dormitory != obshejitie.number_of_dormitory OR number_of_dormitory IS NULL
            ORDER BY id
            LIMIT obshejitie.nado_studentov
            OFFSET schetchik
        );
        
        schetchik := schetchik + obshejitie.nado_studentov;
    END LOOP;
    
    DROP TABLE raspredelenie;
    
    RETURN 'Студенты распределены. В среднем: ' || na_odno_obshejitie || 
           CASE WHEN ostalos_lishnih > 0 THEN ' (+' || ostalos_lishnih || ' общежитий получили по 1 дополнительному студенту)' ELSE '' END;
END;
$$ LANGUAGE plpgsql;


SELECT raspredelit_studentov();


SELECT 
    d.number_of_dormitory AS "Номер общежития",
    d.address AS "Адрес",
    COUNT(s.id) AS "Количество студентов"
FROM dormitory d
LEFT JOIN students s ON d.number_of_dormitory = s.number_of_dormitory
GROUP BY d.number_of_dormitory, d.address
ORDER BY d.number_of_dormitory;

-- Функция для выдачи комплектов белья студентам
CREATE OR REPLACE FUNCTION vydat_bele()
RETURNS TEXT AS $$
DECLARE
    bez_bele INT;      
    svobodnogo_bele INT; 
    vydano INT := 0;   
    obshejitie RECORD;
BEGIN

    SELECT COUNT(*) INTO bez_bele FROM students WHERE liner_serial_number IS NULL;
    SELECT COUNT(*) INTO svobodnogo_bele FROM set_of_liner WHERE student_id IS NULL;
    

    IF bez_bele = 0 THEN RETURN 'Все студенты уже получили белье'; END IF;
    IF svobodnogo_bele = 0 THEN RETURN 'Нет свободных комплектов белья'; END IF;
    

    FOR obshejitie IN SELECT DISTINCT number_of_dormitory FROM dormitory ORDER BY number_of_dormitory
    LOOP

        WITH studenti_bez_bele AS (
            SELECT id FROM students 
            WHERE number_of_dormitory = obshejitie.number_of_dormitory AND liner_serial_number IS NULL
            ORDER BY id
            FOR UPDATE
        ),
        svobodnoe_bele AS (
            SELECT serial_number FROM set_of_liner 
            WHERE number_of_dormitory = obshejitie.number_of_dormitory AND student_id IS NULL
            ORDER BY serial_number
            FOR UPDATE
        ),
        raspredelenie AS (
            SELECT 
                s.id AS student_id,
                (SELECT serial_number FROM svobodnoe_bele ORDER BY serial_number LIMIT 1 OFFSET rn) AS nomer_bele
            FROM (
                SELECT id, ROW_NUMBER() OVER () - 1 AS rn FROM studenti_bez_bele
            ) s
        )

        UPDATE students st
        SET liner_serial_number = r.nomer_bele
        FROM raspredelenie r
        WHERE st.id = r.student_id AND r.nomer_bele IS NOT NULL;
        

        GET DIAGNOSTICS vydano = ROW_COUNT;
    END LOOP;
    

    UPDATE set_of_liner sl
    SET student_id = s.id
    FROM students s
    WHERE s.liner_serial_number = sl.serial_number AND sl.student_id IS NULL;
    
    RETURN 'Выдано ' || vydano || ' комплектов белья';
END;
$$ LANGUAGE plpgsql;


SELECT vydat_bele();

-- Проверяем результат
SELECT 
    d.number_of_dormitory AS "Номер общежития",
    COUNT(s.id) AS "Всего студентов",
    COUNT(s.liner_serial_number) AS "С бельем",
    COUNT(CASE WHEN sl.student_id IS NULL THEN 1 END) AS "Свободных комплектов"
FROM dormitory d
LEFT JOIN students s ON d.number_of_dormitory = s.number_of_dormitory
LEFT JOIN set_of_liner sl ON d.number_of_dormitory = sl.number_of_dormitory
GROUP BY d.number_of_dormitory
ORDER BY d.number_of_dormitory;

-- Статистика по общежитиям
SELECT 
    d.number_of_dormitory AS "number",
    d.address AS "addres",
    d.number_of_floor AS "number_of_floor",
    stats.students AS "students",
    ROUND(stats.avg_age) AS "AGE",
    stats.liner_stats AS "liner_stats"
FROM dormitory d
JOIN LATERAL (
    SELECT 
        COUNT(s.id) AS students,
        AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.date_of_birth))) AS avg_age,
        jsonb_build_object(
            'новое', COUNT(CASE WHEN sl.state = 'new' THEN 1 END),
            'хорошее', COUNT(CASE WHEN sl.state = 'good' THEN 1 END),
            'использованное', COUNT(CASE WHEN sl.state = 'used' THEN 1 END),
            'плохое', COUNT(CASE WHEN sl.state = 'bad' THEN 1 END)
        ) AS liner_stats
    FROM students s
    LEFT JOIN set_of_liner sl ON s.id = sl.student_id
    WHERE s.number_of_dormitory = d.number_of_dormitory
    GROUP BY s.number_of_dormitory
) stats ON true
ORDER BY stats.students DESC;

