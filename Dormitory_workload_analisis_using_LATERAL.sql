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