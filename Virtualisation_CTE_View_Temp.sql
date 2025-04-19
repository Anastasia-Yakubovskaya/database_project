-- 1. Создание временной таблицы для зданий в плохом состоянии
CREATE TEMP TABLE IF NOT EXISTS bad_condition AS
SELECT * FROM university_building
WHERE building_condition = 'Poor';

-- Вывод результатов
SELECT * FROM bad_condition;

-- 2. Создание временной таблицы с количеством зданий в плохом состоянии
CREATE TEMP TABLE IF NOT EXISTS bad_condition_summary AS 
SELECT  
    number_of_building,  
    COUNT(*) AS bad_buildings_count  
FROM university_building  
WHERE building_condition = 'Poor'  
GROUP BY number_of_building;  

-- Вывод результатов (первые 5 записей)
SELECT * FROM bad_condition_summary LIMIT 5;

-- 3. Анализ студентов по году рождения (WITH запрос)
WITH students_by_year AS (
    SELECT
        EXTRACT(YEAR FROM date_of_birth) AS birth_year,
        COUNT(*) AS students_count
    FROM students
    GROUP BY birth_year
)
-- Вывод результатов с сортировкой
SELECT * FROM students_by_year
ORDER BY birth_year;

-- 4. Создание представления для студентов, родившихся до 2006 года
CREATE OR REPLACE VIEW students_before_2006 AS
SELECT id, name, date_of_birth, number_of_dormitory
FROM students
WHERE EXTRACT(YEAR FROM date_of_birth) < 2006;

-- Вывод результатов из представления
SELECT * FROM students_before_2006;