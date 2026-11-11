-- =====================================================================
--  2026-01-29  Paringud (world)  -  I osa
--  Jegor Onoprijuk, ruhm TA-24B
-- =====================================================================
USE world;

-- 1. Leia koik riigid, mille riigipea nimi algab U-tahega
SELECT Code, Name, HeadOfState
FROM country
WHERE HeadOfState LIKE 'U%'
ORDER BY Name;

-- 2. Leia koik riigid, mille riigipea nimes on z taht
SELECT Code, Name, HeadOfState
FROM country
WHERE HeadOfState LIKE '%z%'
ORDER BY Name;

-- 3. Leia 3 riigipead, kes valitsevad koige enam arvu riike
SELECT HeadOfState AS riigipea, COUNT(*) AS riike, GROUP_CONCAT(Name ORDER BY Name SEPARATOR ', ') AS riigid
FROM country
WHERE HeadOfState IS NOT NULL AND HeadOfState <> ''
GROUP BY HeadOfState
ORDER BY riike DESC, riigipea
LIMIT 3;

-- 4. Leia riigid, mis on pindalalt vahemalt 21.-st 40.-nda kohani
--    (jarjestan pindala jargi kahanevalt, jatan esimesed 20 vahele, votan jargmised 20)
SELECT ROW_NUMBER() OVER (ORDER BY SurfaceArea DESC) + 20 AS koht, Name, SurfaceArea
FROM (SELECT Name, SurfaceArea FROM country ORDER BY SurfaceArea DESC LIMIT 20 OFFSET 20) t
ORDER BY SurfaceArea DESC;

-- 5. Leia Ameerika riikide keskmine eluiga
--    (Ameerika = North America + South America)
SELECT ROUND(AVG(LifeExpectancy), 2) AS keskmine_eluiga, COUNT(LifeExpectancy) AS riike
FROM country
WHERE Continent IN ('North America', 'South America');

-- 6. Leia Ameerika inimeste keskmine eluiga (riikide kaalutud keskmine -
--    iga riigi eluiga kaalutakse tema rahvaarvuga)
SELECT ROUND(SUM(LifeExpectancy * Population) / SUM(Population), 2) AS kaalutud_keskmine_eluiga,
       SUM(Population) AS rahvaarv_kokku
FROM country
WHERE Continent IN ('North America', 'South America')
  AND LifeExpectancy IS NOT NULL AND Population > 0;

-- 7. Leia, millisel kontinendil on koige enam vabariike
--    (vabariik = valitsemisvorm sisaldab sona "Republic")
SELECT Continent, COUNT(*) AS vabariike
FROM country
WHERE GovernmentForm LIKE '%Republic%'
GROUP BY Continent
ORDER BY vabariike DESC;

-- 8. Leia, mitmes riigis ja mis kontinentidel raagitakse portugali keelt
--    ning mitu inimest seda raagib uldse ja mitu ametliku keelena
SELECT COUNT(DISTINCT cl.CountryCode)                                  AS riike,
       GROUP_CONCAT(DISTINCT c.Continent ORDER BY c.Continent SEPARATOR ', ') AS kontinendid
FROM countrylanguage cl JOIN country c ON c.Code = cl.CountryCode
WHERE cl.Language = 'Portuguese';

SELECT ROUND(SUM(c.Population * cl.Percentage / 100))                       AS raagib_uldse,
       ROUND(SUM(CASE WHEN cl.IsOfficial = 'T'
                      THEN c.Population * cl.Percentage / 100 END))         AS raagib_ametliku_keelena
FROM countrylanguage cl JOIN country c ON c.Code = cl.CountryCode
WHERE cl.Language = 'Portuguese';

-- 8b. riikide kaupa (kontrolliks)
SELECT c.Name AS riik, c.Continent AS kontinent, cl.IsOfficial AS ametlik, cl.Percentage AS protsent,
       ROUND(c.Population * cl.Percentage / 100) AS raagib
FROM countrylanguage cl JOIN country c ON c.Code = cl.CountryCode
WHERE cl.Language = 'Portuguese'
ORDER BY raagib DESC;
