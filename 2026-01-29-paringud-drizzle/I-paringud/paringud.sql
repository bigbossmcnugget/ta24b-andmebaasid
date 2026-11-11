-- =====================================================================
--  2026-01-29  Paringud (world)  -  I osa
--  Jegor Onoprijuk, ruhm TA-24B
-- =====================================================================
USE world;

SELECT '=== 1. riigipea nimi algab U-ga ===' AS paring;
-- 1. Leia koik riigid, mille riigipea nimi algab U-tahega
--    a) kogu nimi (esimene eesnimi) algab U-ga
SELECT Code, Name, HeadOfState
FROM country
WHERE HeadOfState LIKE 'U%'
ORDER BY Name;
SELECT COUNT(*) AS ridu_1a_nimi_algab_U FROM country WHERE HeadOfState LIKE 'U%';
--    (tulemus: 0 - andmebaasis ei ole uhtegi riigipead, kelle nimi algaks U-ga)
--    b) mone nimeosa (nt perekonnanimi) algab U-ga
SELECT Code, Name, HeadOfState
FROM country
WHERE HeadOfState LIKE 'U%' OR HeadOfState LIKE '% U%'
ORDER BY Name;

SELECT '=== 2. riigipea nimes on z ===' AS paring;
-- 2. Leia koik riigid, mille riigipea nimes on z taht
SELECT Code, Name, HeadOfState
FROM country
WHERE HeadOfState LIKE '%z%'
ORDER BY Name;

SELECT '=== 3. kolm riigipead, kes valitsevad koige rohkem riike ===' AS paring;
-- 3. Leia 3 riigipead, kes valitsevad koige enam arvu riike
SELECT HeadOfState AS riigipea, COUNT(*) AS riike, GROUP_CONCAT(Name ORDER BY Name SEPARATOR ', ') AS riigid
FROM country
WHERE HeadOfState IS NOT NULL AND HeadOfState <> ''
GROUP BY HeadOfState
ORDER BY riike DESC, riigipea
LIMIT 3;

SELECT '=== 4. pindala jargi 21.-40. koht ===' AS paring;
-- 4. Leia riigid, mis on pindalalt vahemalt 21.-st 40.-nda kohani
--    (jarjestan pindala jargi kahanevalt, jatan esimesed 20 vahele, votan jargmised 20)
SELECT ROW_NUMBER() OVER (ORDER BY SurfaceArea DESC) + 20 AS koht, Name, SurfaceArea
FROM (SELECT Name, SurfaceArea FROM country ORDER BY SurfaceArea DESC LIMIT 20 OFFSET 20) t
ORDER BY SurfaceArea DESC;

SELECT '=== 5. Ameerika riikide keskmine eluiga ===' AS paring;
-- 5. Leia Ameerika riikide keskmine eluiga
--    (Ameerika = North America + South America)
SELECT ROUND(AVG(LifeExpectancy), 2) AS keskmine_eluiga, COUNT(LifeExpectancy) AS riike
FROM country
WHERE Continent IN ('North America', 'South America');

SELECT '=== 6. Ameerika inimeste keskmine eluiga (kaalutud) ===' AS paring;
-- 6. Leia Ameerika inimeste keskmine eluiga (riikide kaalutud keskmine -
--    iga riigi eluiga kaalutakse tema rahvaarvuga)
SELECT ROUND(SUM(LifeExpectancy * Population) / SUM(Population), 2) AS kaalutud_keskmine_eluiga,
       SUM(Population) AS rahvaarv_kokku
FROM country
WHERE Continent IN ('North America', 'South America')
  AND LifeExpectancy IS NOT NULL AND Population > 0;

SELECT '=== 7. kontinent, kus on koige rohkem vabariike ===' AS paring;
-- 7. Leia, millisel kontinendil on koige enam vabariike
--    (vabariik = valitsemisvorm sisaldab sona "Republic")
SELECT Continent, COUNT(*) AS vabariike
FROM country
WHERE GovernmentForm LIKE '%Republic%'
GROUP BY Continent
ORDER BY vabariike DESC;

SELECT '=== 8. portugali keel ===' AS paring;
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
