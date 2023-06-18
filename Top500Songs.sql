------------------------------------------------Cleaning Section-----------------------------------------------------------
	SELECT * 
FROM Songs 
WHERE 
    CHARINDEX('é', title) > 0 OR CHARINDEX('’', title) > 0 OR CHARINDEX('�', title) > 0 OR
    CHARINDEX('é', description) > 0 OR CHARINDEX('’', description) > 0 OR CHARINDEX('�', description) > 0 OR
    CHARINDEX('é', appears_on) > 0 OR CHARINDEX('’', appears_on) > 0 OR CHARINDEX('�', appears_on) > 0 OR
    CHARINDEX('é', artist) > 0 OR CHARINDEX('’', artist) > 0 OR CHARINDEX('�', artist) > 0 OR
    CHARINDEX('é', writers) > 0 OR CHARINDEX('’', writers) > 0 OR CHARINDEX('�', writers) > 0 OR
    CHARINDEX('é', producer) > 0 OR CHARINDEX('’', producer) > 0 OR CHARINDEX('�', producer) > 0 OR
    CHARINDEX('é', released) > 0 OR CHARINDEX('’', released) > 0 OR CHARINDEX('�', released) > 0 OR
    CHARINDEX('é', streak) > 0 OR CHARINDEX('’', streak) > 0 OR CHARINDEX('�', streak) > 0 OR
    CHARINDEX('é', position) > 0 OR CHARINDEX('’', position) > 0 OR CHARINDEX('�', position) > 0;


UPDATE Songs 
SET 
    title = REPLACE(REPLACE(REPLACE(title, 'é', 'e'), '’', ''''), '�', ''),
    description = REPLACE(REPLACE(REPLACE(description, 'é', 'e'), '’', ''''), '�', ''),
    appears_on = REPLACE(REPLACE(REPLACE(appears_on, 'é', 'e'), '’', ''''), '�', ''),
    artist = REPLACE(REPLACE(REPLACE(artist, 'é', 'e'), '’', ''''), '�', ''),
    writers = REPLACE(REPLACE(REPLACE(writers, 'é', 'e'), '’', ''''), '�', ''),
    producer = REPLACE(REPLACE(REPLACE(producer, 'é', 'e'), '’', ''''), '�', ''),
    released = REPLACE(REPLACE(REPLACE(released, 'é', 'e'), '’', ''''), '�', ''),
    streak = REPLACE(REPLACE(REPLACE(streak, 'é', 'e'), '’', ''''), '�', ''),
    position = REPLACE(REPLACE(REPLACE(position, 'é', 'e'), '’', ''''), '�', '');

	UPDATE Songs 
SET writers = REPLACE(writers, 'ö', '�');


	SELECT * 
FROM Songs 
WHERE 
  CHARINDEX(',', streak) > 0 

UPDATE Songs
SET 
  position = CASE
    WHEN CHARINDEX(',', streak) > 0 THEN LTRIM(RTRIM(SUBSTRING(streak, CHARINDEX(',', streak) + 1, LEN(streak))))
    ELSE position
  END,
  streak = CASE
    WHEN CHARINDEX(',', streak) > 0 THEN LTRIM(RTRIM(SUBSTRING(streak, 1, CHARINDEX(',', streak) - 1)))
    ELSE streak
  END;


  UPDATE Songs
SET position = COALESCE(position, 'none')
WHERE position IS NULL;

---------------------------------------------------------------------------Exploratory Section------------------------------------------------------
---------------------1. Song with the most appearances--------------------
SELECT title, COUNT(*) as count, RANK() OVER (ORDER BY COUNT(*) DESC) as rank
FROM PortfolioProject..Songs 
GROUP BY title
HAVING COUNT(*) > 1;

---------------------2. Artist with the most appearances--------------------
SELECT artist, COUNT(*) as count, RANK() OVER (ORDER BY COUNT(*) DESC) as rank
FROM PortfolioProject..Songs 
GROUP BY artist
HAVING COUNT(*) > 1;

--------------------------3. producer with the most songs----------------------------
WITH names AS (
    SELECT TRIM(value) AS producer
    FROM Songs
    CROSS APPLY STRING_SPLIT(producer, ',')
),
counts AS (
    SELECT producer, COUNT(*) AS count
    FROM names
    GROUP BY producer
)
SELECT producer, count
FROM counts
ORDER BY count DESC;

--------------------------4. writer with the most songs----------------------------
WITH names AS (
    SELECT TRIM(value) AS writers
    FROM Songs
    CROSS APPLY STRING_SPLIT(writers, ',')
),
counts AS (
    SELECT writers, COUNT(*) AS count
    FROM names
    GROUP BY writers
)
SELECT writers, count
FROM counts
ORDER BY count DESC;