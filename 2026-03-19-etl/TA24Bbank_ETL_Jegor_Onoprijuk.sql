-- =====================================================================
-- TA24Bbank - 19.03.2026 ülesanne
-- Accounts, Customers, ETL, stored procedure
-- Jegor Onoprijuk, rühm TA-24B
--
-- Lähtekoht: Dump20260319.sql (2 klienti, 2 kontot, customer-triggerid)
--
-- Mida see fail teeb:
--   1. log ja account_balance tabelid, customer-tabelile puuduvad veerud
--   2. account-triggerid: jäägi muutus -> account_balance, muu -> audit
--   3. protseduurid open_current_account ja transfer
--   4. ETL: ourcustomers.csv -> andmebaas etl (vahetabel) -> customer
--   5. käivitamine ja kontroll
--
-- Kontrollitud MariaDB 13 peal, kõik laused jooksid läbi veata.
-- Käivitamine (CSV peab olema samas kaustas):
--   mysql --local-infile=1 -u <kasutaja> -p < TA24Bbank_ETL_Jegor_Onoprijuk.sql
-- =====================================================================


USE TA24Bbank;

-- ---------------------------------------------------------------------
-- 1. Vigade ja teadete tabel
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `log`;
CREATE TABLE `log` (
  `id`        bigint unsigned NOT NULL AUTO_INCREMENT,
  `message`   varchar(512) DEFAULT NULL,
  `createdat` datetime     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 2. Konto jäägi ajalugu
--    Siia kirjutab trigger VANA jäägi iga kord, kui balance muutub.
--    Nii on alati näha, mis seis oli enne tehingut.
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS `account_balance`;
CREATE TABLE `account_balance` (
  `id`            bigint unsigned NOT NULL AUTO_INCREMENT,
  `accountnumber` bigint unsigned NOT NULL,
  `balance`       decimal(12,2) NOT NULL,
  `createdat`     datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ab_account` (`accountnumber`,`createdat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 3. customer tabelile puuduvad veerud
--    CSV-s on lisaks telefon, aadressi teine ja kolmas rida ning sugu.
-- ---------------------------------------------------------------------
ALTER TABLE `customer`
  ADD COLUMN `phone`    varchar(32) DEFAULT NULL AFTER `customertype`,
  ADD COLUMN `address2` varchar(64) DEFAULT NULL AFTER `phone`,
  ADD COLUMN `address3` varchar(64) DEFAULT NULL AFTER `address2`,
  ADD COLUMN `gender`   varchar(8)  DEFAULT NULL AFTER `address3`;

-- ---------------------------------------------------------------------
-- 4. account tabelile välisvõtmed (19.03 seisuga neid ei olnud)
-- ---------------------------------------------------------------------
ALTER TABLE `account`
  ADD KEY `idx_acc_customer` (`customerid`),
  ADD KEY `idx_acc_type` (`accounttype`),
  ADD CONSTRAINT `account_ibfk_1` FOREIGN KEY (`customerid`)  REFERENCES `customer` (`idcode`),
  ADD CONSTRAINT `account_ibfk_2` FOREIGN KEY (`accounttype`) REFERENCES `accounttype` (`type`);

USE TA24Bbank;

-- ---------------------------------------------------------------------
-- Account triggerid. Customeril olid need juba olemas, accountil mitte.
-- ---------------------------------------------------------------------
DROP TRIGGER IF EXISTS after_account_insert;
DROP TRIGGER IF EXISTS after_account_update;
DROP TRIGGER IF EXISTS after_account_delete;

DELIMITER //

CREATE TRIGGER after_account_insert AFTER INSERT ON account FOR EACH ROW
BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('ACCOUNT', NEW.accountnumber, 'INS', USER());
END//

-- Siin on ülesande põhimõte: kui muutub JÄÄK, siis ei lähe see audit'i,
-- vaid account_balance ajalukku (salvestan VANA jäägi, sest uus on juba
-- account-tabelis näha). Kõik muud muudatused lähevad audit'i.
CREATE TRIGGER after_account_update AFTER UPDATE ON account FOR EACH ROW
BEGIN
    IF OLD.balance <> NEW.balance THEN
        INSERT INTO account_balance (accountnumber, balance)
        VALUES (OLD.accountnumber, OLD.balance);
    ELSE
        INSERT INTO audit (tablename, tableid, operation, user)
        VALUES ('ACCOUNT', NEW.accountnumber, 'UPD', USER());
    END IF;
END//

CREATE TRIGGER after_account_delete AFTER DELETE ON account FOR EACH ROW
BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('ACCOUNT', OLD.accountnumber, 'DEL', USER());
END//

DELIMITER ;

USE TA24Bbank;

DROP PROCEDURE IF EXISTS open_current_account;
DROP PROCEDURE IF EXISTS transfer;

DELIMITER //

-- ---------------------------------------------------------------------
-- Avab arvelduskonto igale kliendile, kellel seda veel ei ole.
-- ---------------------------------------------------------------------
CREATE PROCEDURE open_current_account()
BEGIN
    DECLARE done BOOLEAN DEFAULT FALSE;
    DECLARE id_code BIGINT;
    DECLARE new_account_number BIGINT;
    DECLARE ac_count INTEGER;
    DECLARE opened INTEGER DEFAULT 0;
    DECLARE customer_cursor CURSOR FOR SELECT idcode FROM customer;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN customer_cursor;
    read_loop: LOOP
        FETCH customer_cursor INTO id_code;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SELECT COUNT(*) INTO ac_count
          FROM account WHERE customerid = id_code AND accounttype = 'CURR';

        IF ac_count = 0 THEN
            SELECT IFNULL(MAX(accountnumber), 100000) + 1
              INTO new_account_number FROM account;
            INSERT INTO account (accountnumber, accounttype, customerid, balance)
            VALUES (new_account_number, 'CURR', id_code, 0);
            SET opened = opened + 1;
        END IF;
    END LOOP;
    CLOSE customer_cursor;

    INSERT INTO log (message)
    VALUES (CONCAT('open_current_account: avati ', opened, ' arvelduskontot'));
END//

-- ---------------------------------------------------------------------
-- Raha kandmine kontode vahel. Kõik ühe tehinguna: kui midagi läheb
-- katki, ei jää raha kuhugi "pooleldi".
-- ---------------------------------------------------------------------
CREATE PROCEDURE transfer(IN p_debaccount BIGINT, IN p_creaccount BIGINT,
                          IN p_sum DECIMAL(12,2), IN p_description VARCHAR(255))
BEGIN
    DECLARE v_balance DECIMAL(12,2);
    DECLARE v_crexists INT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO log (message)
        VALUES (CONCAT('transfer ERROR ', @errno, ' (', @sqlstate, ') ', @text));
    END;

    START TRANSACTION;

    SELECT balance INTO v_balance FROM account
     WHERE accountnumber = p_debaccount FOR UPDATE;
    SELECT COUNT(*) INTO v_crexists FROM account WHERE accountnumber = p_creaccount;

    IF p_sum IS NULL OR p_sum <= 0 THEN
        ROLLBACK;
        INSERT INTO log (message) VALUES (CONCAT('transfer: vigane summa ', IFNULL(p_sum,'NULL')));
    ELSEIF v_balance IS NULL THEN
        ROLLBACK;
        INSERT INTO log (message) VALUES (CONCAT('transfer: deebetkontot ', p_debaccount, ' ei ole'));
    ELSEIF v_crexists = 0 THEN
        ROLLBACK;
        INSERT INTO log (message) VALUES (CONCAT('transfer: kreeditkontot ', p_creaccount, ' ei ole'));
    ELSEIF v_balance - p_sum < 0 THEN
        ROLLBACK;
        INSERT INTO log (message)
        VALUES (CONCAT('transfer: kontol ', p_debaccount, ' ei ole katet (jääk ', v_balance,
                       ', soovitud ', p_sum, ')'));
    ELSE
        UPDATE account SET balance = balance - p_sum WHERE accountnumber = p_debaccount;
        UPDATE account SET balance = balance + p_sum WHERE accountnumber = p_creaccount;
        INSERT INTO log (message)
        VALUES (CONCAT('transfer OK: ', p_debaccount, ' -> ', p_creaccount, ' ', p_sum,
                       ' EUR (', IFNULL(p_description,''), ')'));
        COMMIT;
    END IF;
END//

DELIMITER ;

-- =====================================================================
-- ETL: CSV -> vahetabel -> TA24Bbank.customer
-- Jegor Onoprijuk, TA-24B
--
-- Miks eraldi baas ja vahetabel?
-- CSV-s on andmed nii, nagu nad meile anti: kõik tekstina, osa ridu
-- katki. Kui laadida otse customer-tabelisse, lendab esimese vigase rea
-- peale terve laadimine vastu seina. Vahetabelis on kõik veerud VARCHAR,
-- sinna läheb kõik sisse, ja alles teises sammus puhastan ja teisendan.
-- =====================================================================

DROP DATABASE IF EXISTS etl;
CREATE DATABASE etl CHARACTER SET utf8mb4;
USE etl;

-- Vahetabel: täpselt nii mitu veergu kui CSV-s, kõik tekstina.
CREATE TABLE stg_customer (
  rownum      bigint unsigned NOT NULL AUTO_INCREMENT,
  c1_idkood   varchar(64),
  c2  varchar(255), c3  varchar(255), c4  varchar(255), c5  varchar(255),
  c6  varchar(255), c7  varchar(255), c8  varchar(255), c9  varchar(255),
  c10 varchar(255), c11 varchar(255), c12 varchar(255), c13 varchar(255),
  c14 varchar(255), c15 varchar(255), c16 varchar(255), c17 varchar(255),
  PRIMARY KEY (rownum)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Laadimine. CSV on semikooloniga ja esimene rida on päis.
-- NB! Fail on CRLF-reavahetustega (file ütleb "with CRLF line terminators").
-- Kui kirjutada LINES TERMINATED BY '\n', jääb iga viimase veeru lõppu \r
-- ja kõik võrdlused lähevad nihu - minul läksid esimesel katsel kõik
-- kliendid tüübiks BASIC, sest 'GOLD\r' <> 'GOLD'. TRIM() seda ei eemalda.
LOAD DATA LOCAL INFILE 'ourcustomers.csv'
INTO TABLE stg_customer
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ';'
LINES TERMINATED BY '\r\n'   -- fail on Windowsi reavahetustega (CRLF)
IGNORE 1 LINES
(c1_idkood, c2, c3, c4, c5, c6, c7, c8, c9, c10, c11, c12, c13, c14, c15, c16, c17);

-- Kontroll: mitu rida tuli sisse
SELECT COUNT(*) AS laaditud_ridu FROM stg_customer;

-- ---------------------------------------------------------------------
-- Andmete kvaliteet: osa ridu on nihkes.
-- Normaalne rida:  ... c6=address1, c7=address2, c8=address3, c9=gender ...
-- Vigane rida:     address3 puudub, seega c8=gender ja lõpus on üleliigne
--                  tühi veerg. Neid on andmestikus 82 tükki.
-- Tunnus, mille järgi ma need eristan: kas c9 on 'male'/'female' või mitte.
-- ---------------------------------------------------------------------
SELECT
  SUM(CASE WHEN c9 IN ('male','female') THEN 1 ELSE 0 END) AS korras_ridu,
  SUM(CASE WHEN c8 IN ('male','female') THEN 1 ELSE 0 END) AS nihkes_ridu
FROM stg_customer;

-- Vaade, mis paneb mõlemat sorti read ühtsele kujule.
CREATE OR REPLACE VIEW v_customer_clean AS
SELECT
  CAST(c1_idkood AS UNSIGNED)                               AS idcode,
  NULLIF(TRIM(c2), '')                                      AS firstname,
  NULLIF(TRIM(c3), '')                                      AS lastname,
  NULLIF(TRIM(c4), '')                                      AS email,
  NULLIF(TRIM(c5), '')                                      AS phone,
  NULLIF(TRIM(c6), '')                                      AS address,
  NULLIF(TRIM(c7), '')                                      AS address2,
  CASE WHEN c9 IN ('male','female') THEN NULLIF(TRIM(c8),'') ELSE NULL END AS address3,
  CASE WHEN c9 IN ('male','female') THEN c9 ELSE c8 END     AS gender,
  -- tüüp on alati viimases veerus, sõltumata nihkest
  CASE TRIM(c17)
       WHEN 'GOLD' THEN 'GOLD'
       WHEN 'SILV' THEN 'SILVER'
       WHEN 'TAVA' THEN 'BASIC'
       WHEN 'PRON' THEN 'BRONZE'
       ELSE 'BASIC'                                          -- tundmatu tüüp -> tavaklient
  END                                                        AS customertype
FROM stg_customer;

-- ---------------------------------------------------------------------
-- Laadimine päris tabelisse.
-- INSERT IGNORE, sest kaks klienti (10000 ja 37712212345) on baasis juba
-- olemas ja e-post on UNIQUE - kordust ei tohi tekkida.
-- ---------------------------------------------------------------------
INSERT IGNORE INTO TA24Bbank.customer
      (idcode, firstname, lastname, address, email, customertype, phone, address2, address3, gender)
SELECT idcode, firstname, lastname, address, email, customertype, phone, address2, address3, gender
  FROM v_customer_clean
 WHERE idcode IS NOT NULL
   AND firstname IS NOT NULL
   AND lastname  IS NOT NULL;

SELECT ROW_COUNT() AS sisestatud;

USE TA24Bbank;

-- Avame kõigile klientidele arvelduskonto
CALL open_current_account();

-- Paar tehingut, et triggerid ja ajalugu päriselt tööle hakkaksid.
-- Raha tuleb panga kassakontolt 100001.
SET @k1 = (SELECT accountnumber FROM account WHERE customerid = 3678104567 AND accounttype='CURR');
SET @k2 = (SELECT accountnumber FROM account WHERE customerid = 3678104568 AND accounttype='CURR');
SET @k3 = (SELECT accountnumber FROM account WHERE customerid = 3678104569 AND accounttype='CURR');

CALL transfer(100001, @k1, 1000.00, 'Sularaha sissemakse');
CALL transfer(100001, @k2,  750.00, 'Sularaha sissemakse');
CALL transfer(100001, @k3,  500.00, 'Sularaha sissemakse');
CALL transfer(@k1,    @k2,  120.00, 'Ulekanne sobrale');
CALL transfer(@k2,    @k3,   45.50, 'Arve tasumine');
CALL transfer(@k3,    @k1,  999999.00, 'Katse ilma katteta');

-- muudatus, mis EI puuduta jääki -> peab minema audit'i, mitte ajalukku
UPDATE account SET interestrate = 0.50 WHERE accountnumber = @k1;
