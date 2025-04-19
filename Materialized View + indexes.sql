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




