-- =====================================================================
-- Triggerid ja transaktsioonid - world andmebaas
-- Jegor Onoprijuk, ruhm TA-24B          ulesanne 19.02.2026
--
-- Kaivitamine:
--   mysql -u <kasutaja> -p < triggers_transactions.sql
-- =====================================================================

USE world;

SELECT '=== 0. ALGSEIS ===' AS samm;
SELECT name, headofstate FROM country
 WHERE headofstate IN ('Beatrix','Willem-Alexander') ORDER BY name;


-- =====================================================================
-- OSA 1. TRANSAKTSIOONID
-- =====================================================================

SELECT '=== 1.1 START TRANSACTION + UPDATE + ROLLBACK ===' AS samm;

START TRANSACTION;

UPDATE country
   SET headofstate = 'Willem-Alexander'
 WHERE headofstate = 'Beatrix';

SELECT ROW_COUNT() AS muudetud_ridu;

-- Transaktsiooni SEES naen ma oma muudatust:
SELECT 'transaktsiooni sees' AS kus, name, headofstate FROM country
 WHERE headofstate IN ('Beatrix','Willem-Alexander') ORDER BY name;

ROLLBACK;

-- Parast ROLLBACK-i on koik tagasi nii, nagu enne:
SELECT 'parast rollback' AS kus, name, headofstate FROM country
 WHERE headofstate IN ('Beatrix','Willem-Alexander') ORDER BY name;


SELECT '=== 1.2 Sama asi, aga COMMIT ===' AS samm;

START TRANSACTION;
UPDATE country SET headofstate = 'Willem-Alexander' WHERE headofstate = 'Beatrix';
COMMIT;

SELECT 'parast commit' AS kus, name, headofstate FROM country
 WHERE headofstate IN ('Beatrix','Willem-Alexander') ORDER BY name;

-- Panen algseisu tagasi, et skripti saaks mitu korda jarjest kaivitada.
START TRANSACTION;
UPDATE country SET headofstate = 'Beatrix' WHERE headofstate = 'Willem-Alexander';
COMMIT;


SELECT '=== 1.3 SAVEPOINT - osaline tagasivottmine ===' AS samm;

START TRANSACTION;

UPDATE country SET headofstate = 'Willem-Alexander' WHERE code = 'NLD';
SAVEPOINT peale_hollandit;

UPDATE country SET headofstate = 'VIGANE NIMI'     WHERE code = 'ABW';

SELECT 'enne rollback to savepoint' AS kus, code, name, headofstate
  FROM country WHERE code IN ('NLD','ABW','ANT') ORDER BY code;

-- votan tagasi AINULT viimase muudatuse
ROLLBACK TO SAVEPOINT peale_hollandit;

SELECT 'parast rollback to savepoint' AS kus, code, name, headofstate
  FROM country WHERE code IN ('NLD','ABW','ANT') ORDER BY code;

ROLLBACK;   -- votan ka ulejaanu tagasi


SELECT '=== 1.4 DDL teeb vaikse COMMIT-i ===' AS samm;
-- See on koht, kus ma ise sisse kukkusin. DDL (CREATE/ALTER/DROP) ei
-- kuulu transaktsiooni - ta kinnitab poolelioleva too AUTOMAATSELT ara.

START TRANSACTION;
UPDATE country SET headofstate = 'TEST' WHERE code = 'ABW';

CREATE TABLE ddl_naide (id INT);   -- <- siin toimub implicit commit

ROLLBACK;   -- ei aita enam midagi

SELECT 'parast "rollbackki"' AS kus, code, name, headofstate
  FROM country WHERE code = 'ABW';

-- koristan ara
DROP TABLE ddl_naide;
UPDATE country SET headofstate = 'Beatrix' WHERE code = 'ABW';


-- =====================================================================
-- OSA 2. TRIGGERID
-- =====================================================================

SELECT '=== 2.1 Logitabel ja triggerid ===' AS samm;

DROP TRIGGER IF EXISTS country_before_update;
DROP TRIGGER IF EXISTS country_after_update;
DROP TRIGGER IF EXISTS city_after_insert;
DROP TABLE IF EXISTS country_log;

CREATE TABLE country_log (
  id         BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code       CHAR(3)      NOT NULL,
  valja      VARCHAR(32)  NOT NULL,     -- mis vali muutus
  vana_vaart VARCHAR(100),
  uus_vaart  VARCHAR(100),
  kasutaja   VARCHAR(64)  NOT NULL,
  muudetud   DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_log_code (code)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

DELIMITER //

-- BEFORE-trigger: kontrollib andmeid ENNE salvestamist ja votab
-- vigase rea vastu SIGNAL-iga. AFTER-triggeriga seda teha ei saaks,
-- sest siis oleks rida juba kirjas.
CREATE TRIGGER country_before_update BEFORE UPDATE ON country FOR EACH ROW
BEGIN
    IF NEW.population < 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Rahvaarv ei saa olla negatiivne';
    END IF;
END//

-- AFTER-trigger: kirjutab muudatuse logisse. Login ainult siis, kui
-- vali pariselt muutus - muidu tekiks iga UPDATE pealt prugi.
CREATE TRIGGER country_after_update AFTER UPDATE ON country FOR EACH ROW
BEGIN
    IF NOT (OLD.headofstate <=> NEW.headofstate) THEN
        INSERT INTO country_log (code, valja, vana_vaart, uus_vaart, kasutaja)
        VALUES (OLD.code, 'headofstate', OLD.headofstate, NEW.headofstate, USER());
    END IF;

    IF OLD.population <> NEW.population THEN
        INSERT INTO country_log (code, valja, vana_vaart, uus_vaart, kasutaja)
        VALUES (OLD.code, 'population', OLD.population, NEW.population, USER());
    END IF;
END//

CREATE TRIGGER city_after_insert AFTER INSERT ON city FOR EACH ROW
BEGIN
    INSERT INTO country_log (code, valja, vana_vaart, uus_vaart, kasutaja)
    VALUES (NEW.countrycode, 'uus linn', NULL, NEW.name, USER());
END//

DELIMITER ;


SELECT '=== 2.2 Trigger tootab ===' AS samm;

UPDATE country SET headofstate = 'Willem-Alexander' WHERE headofstate = 'Beatrix';
UPDATE country SET population = population + 1000 WHERE code = 'EST';
INSERT INTO city (name, countrycode, district, population)
VALUES ('Jegorilinn', 'EST', 'Harjumaa', 1234);

SELECT id, code, valja, vana_vaart, uus_vaart, kasutaja FROM country_log ORDER BY id;


SELECT '=== 2.3 Trigger on osa samast transaktsioonist ===' AS samm;
-- Oluline koht: triggeri tehtud INSERT ei ole eraldi asi. Kui pea-
-- muudatus votta tagasi, kaob ka logirida.

SELECT COUNT(*) AS logiridu_enne FROM country_log;

START TRANSACTION;
UPDATE country SET headofstate = 'Kuningas Proovikivi' WHERE code = 'NLD';
SELECT COUNT(*) AS logiridu_transaktsiooni_sees FROM country_log;
ROLLBACK;

SELECT COUNT(*) AS logiridu_parast_rollbacki FROM country_log;


SELECT '=== 2.4 BEFORE-trigger votab vigase rea vastu ===' AS samm;
-- See UPDATE peab andma vea 1644 "Rahvaarv ei saa olla negatiivne"
UPDATE country SET population = -5 WHERE code = 'EST';


SELECT '=== 2.5 Kontroll, et vigane rida ei lainud labi ===' AS samm;
SELECT code, name, population FROM country WHERE code = 'EST';


-- koristan enda tehtud muudatused ara
DELETE FROM city WHERE name = 'Jegorilinn';
UPDATE country SET headofstate = 'Beatrix' WHERE headofstate = 'Willem-Alexander';
UPDATE country SET population = population - 1000 WHERE code = 'EST';

SELECT '=== 3. LOPPSEIS ===' AS samm;
SELECT name, headofstate FROM country
 WHERE headofstate IN ('Beatrix','Willem-Alexander') ORDER BY name;
SELECT COUNT(*) AS logiridu_kokku FROM country_log;
