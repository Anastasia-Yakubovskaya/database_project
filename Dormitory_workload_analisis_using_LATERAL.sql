CREATE OR REPLACE FUNCTION redistribute_students_evenly()
RETURNS TEXT AS $$
DECLARE
    total_students INT;
    total_dormitories INT;
    students_per_dormitory INT;
    remainder INT;
    dormitory_rec RECORD;
    student_counter INT := 0;
BEGIN
    -- Получаем общее количество студентов и общежитий
    SELECT COUNT(*) INTO total_students FROM students;
    SELECT COUNT(*) INTO total_dormitories FROM dormitory;
    
    -- Рассчитываем базовое количество студентов на общежитие и остаток
    students_per_dormitory := total_students / total_dormitories;
    remainder := total_students % total_dormitories;
    
    -- Создаем временную таблицу для хранения порядка распределения
    CREATE TEMP TABLE temp_dorm_order AS
    SELECT number_of_dormitory, 
           students_per_dormitory + 
           CASE WHEN ROW_NUMBER() OVER () <= remainder THEN 1 ELSE 0 END AS target_count
    FROM dormitory
    ORDER BY number_of_dormitory;
    
    -- Распределяем всех студентов за один проход
    FOR dormitory_rec IN SELECT * FROM temp_dorm_order ORDER BY number_of_dormitory
    LOOP
        -- Обновляем общежитие для группы студентов
        UPDATE students
        SET number_of_dormitory = dormitory_rec.number_of_dormitory
        WHERE id IN (
            SELECT id 
            FROM students
            WHERE number_of_dormitory != dormitory_rec.number_of_dormitory OR number_of_dormitory IS NULL
            ORDER BY id
            LIMIT dormitory_rec.target_count
            OFFSET student_counter
        );
        
        student_counter := student_counter + dormitory_rec.target_count;
    END LOOP;
    
    -- Удаляем временную таблицу
    DROP TABLE temp_dorm_order;
    
    -- Возвращаем отчет о выполнении
    RETURN 'Все студенты успешно перераспределены. ' || 
           'Среднее количество студентов на общежитие: ' || students_per_dormitory || 
           CASE WHEN remainder > 0 THEN ' (+' || remainder || ' общежития получили по 1 дополнительному студенту)' ELSE '' END;
END;
$$ LANGUAGE plpgsql;


-- Выполнить перераспределение
SELECT redistribute_students_evenly();

-- Проверить результат
SELECT 
    d.number_of_dormitory,
    d.address,
    COUNT(s.id) AS students_count
FROM dormitory d
LEFT JOIN students s ON d.number_of_dormitory = s.number_of_dormitory
GROUP BY d.number_of_dormitory, d.address
ORDER BY d.number_of_dormitory;

CREATE OR REPLACE FUNCTION assign_liners_to_students()
RETURNS TEXT AS $$
DECLARE
    unassigned_students INT;
    unassigned_liners INT;
    assigned_count INT := 0;
    dormitory_rec RECORD;
BEGIN
    -- Проверяем количество студентов без комплектов и свободных комплектов
    SELECT COUNT(*) INTO unassigned_students 
    FROM students 
    WHERE liner_serial_number IS NULL;
    
    SELECT COUNT(*) INTO unassigned_liners 
    FROM set_of_liner 
    WHERE student_id IS NULL;
    
    -- Если нет студентов без комплектов
    IF unassigned_students = 0 THEN
        RETURN 'Все студенты уже имеют комплекты белья';
    END IF;
    
    -- Если нет свободных комплектов
    IF unassigned_liners = 0 THEN
        RETURN 'Нет свободных комплектов белья для назначения';
    END IF;
    
    -- Распределяем комплекты по общежитиям
    FOR dormitory_rec IN 
        SELECT DISTINCT number_of_dormitory FROM dormitory ORDER BY number_of_dormitory
    LOOP
        -- Назначаем комплекты студентам в текущем общежитии
        WITH dorm_students AS (
            SELECT id 
            FROM students 
            WHERE number_of_dormitory = dormitory_rec.number_of_dormitory 
            AND liner_serial_number IS NULL
            ORDER BY id
            FOR UPDATE
        ),
        dorm_liners AS (
            SELECT serial_number 
            FROM set_of_liner 
            WHERE number_of_dormitory = dormitory_rec.number_of_dormitory 
            AND student_id IS NULL
            ORDER BY serial_number
            FOR UPDATE
        ),
        assignments AS (
            SELECT 
                ds.id AS student_id,
                (SELECT serial_number FROM dorm_liners ORDER BY serial_number LIMIT 1 OFFSET rn) AS liner_serial
            FROM (
                SELECT id, ROW_NUMBER() OVER () - 1 AS rn 
                FROM dorm_students
            ) ds
        )
        UPDATE students s
        SET liner_serial_number = a.liner_serial
        FROM assignments a
        WHERE s.id = a.student_id
        AND a.liner_serial IS NOT NULL;
        
        -- Обновляем счетчик назначенных комплектов
        GET DIAGNOSTICS assigned_count = ROW_COUNT;
    END LOOP;
    
    -- Обновляем обратную связь в таблице комплектов
    UPDATE set_of_liner sl
    SET student_id = s.id
    FROM students s
    WHERE s.liner_serial_number = sl.serial_number
    AND sl.student_id IS NULL;
    
    RETURN 'Успешно назначено ' || assigned_count || ' комплектов белья';
END;
$$ LANGUAGE plpgsql;

-- Выполнить распределение
SELECT assign_liners_to_students();

-- Проверить результат
SELECT 
    d.number_of_dormitory,
    COUNT(s.id) AS students_count,
    COUNT(s.liner_serial_number) AS students_with_liners,
    COUNT(CASE WHEN sl.student_id IS NULL THEN 1 END) AS free_liners
FROM dormitory d
LEFT JOIN students s ON d.number_of_dormitory = s.number_of_dormitory
LEFT JOIN set_of_liner sl ON d.number_of_dormitory = sl.number_of_dormitory
GROUP BY d.number_of_dormitory
ORDER BY d.number_of_dormitory;


SELECT 
    d.number_of_dormitory,
    d.address,  -- Исправлено: было 'adress' вместо 'address'
    d.number_of_floor,
    stats.students_count,
    stats.avg_age,
    stats.underwear_status
FROM dormitory d
JOIN LATERAL (
    SELECT 
        COUNT(s.id) AS students_count,
        AVG(EXTRACT(YEAR FROM AGE(CURRENT_DATE, s.date_of_birth))) AS avg_age,  -- Исправлена функция AGE
        jsonb_build_object(
            'new', COUNT(CASE WHEN sl.state = 'new' THEN 1 END),  -- Исправлено: 'su' на 'sl' (set_of_liner)
            'good', COUNT(CASE WHEN sl.state = 'good' THEN 1 END),
            'used', COUNT(CASE WHEN sl.state = 'used' THEN 1 END),
            'bad', COUNT(CASE WHEN sl.state = 'bad' THEN 1 END)  -- Добавлено для полноты
        ) AS underwear_status
    FROM students s
    LEFT JOIN set_of_liner sl ON s.id = sl.student_id  -- Исправлено: 'set_of_underwear' на 'set_of_liner'
    WHERE s.number_of_dormitory = d.number_of_dormitory
    GROUP BY s.number_of_dormitory  -- Добавлена группировка
) stats ON true
ORDER BY stats.students_count DESC;