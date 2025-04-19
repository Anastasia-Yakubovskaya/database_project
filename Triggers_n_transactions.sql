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