SELECT
    EXTRACT(YEAR FROM date_of_birth) AS birth_year,
    COUNT(*) AS year_of_count,
    STRING_AGG(name, ', ' ORDER BY name) AS staffs
FROM
    staff
WHERE
    sex = 'Female'
GROUP BY
    EXTRACT(YEAR FROM date_of_birth)
HAVING
    EXTRACT(YEAR FROM date_of_birth) > 1980 
ORDER BY
    birth_year;