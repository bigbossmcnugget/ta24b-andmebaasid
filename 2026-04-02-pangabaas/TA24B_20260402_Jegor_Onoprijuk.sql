-- =====================================================================
-- TA24Bbank - "Algeline pangabaas" (02.04.2026 ülesanne)
-- Jegor Onoprijuk, rühm TA-24B
--
-- Mida see fail teeb:
--   1. LAENUD      - loantype, loan, loanschedule, loanpayment
--   2. DATES       - 2026. aasta pangapäevade kalender (B/H),
--                    sees ka Eesti riigipühad
--   3. CONFIG      - key-value parameetrid (KP, NAME, PANGAKOOD)
--   4. PROTSEDUURID- next_banking_day() nihutab pangapäeva ühe äripäeva
--                    võrra edasi; lisaks laenugraafiku protseduurid
--   5. NÄIDED      - läbi testitud kutsed ja kontrollpäringud
--
-- Kontrollitud: MariaDB 13 (MySQL-ühilduv), baasile laaditi enne
-- õpetaja dump TA24B_20260402.sql (920 klienti, 922 kontot).
-- Kõik selle faili laused jooksid läbi veata.
--
-- Käivitamine:
--   mysql -u <kasutaja> -p TA24Bbank < TA24B_20260402_Jegor_Onoprijuk.sql
-- =====================================================================

--   4) protseduurid     (pangapäeva nihutamine, maksegraafiku koostamine)
--
-- Andmebaas: MySQL 8 / MariaDB, baas TA24Bbank
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. LAENUD
-- ---------------------------------------------------------------------

DROP TABLE IF EXISTS `loanpayment`;
DROP TABLE IF EXISTS `loanschedule`;
DROP TABLE IF EXISTS `loan`;
DROP TABLE IF EXISTS `loantype`;

-- Laenutooted. Hoian eraldi tabelis samamoodi nagu accounttype ja customertype,
-- et laenu liik oleks välisvõtmega kontrollitud, mitte vaba tekst.
CREATE TABLE `loantype` (
  `type`        char(6)      NOT NULL,
  `description` varchar(255) NOT NULL,
  `maxmonths`   smallint unsigned NOT NULL,          -- lühiajaline laen: kuni 12 kuud
  `minamount`   decimal(12,2) NOT NULL DEFAULT 100.00,
  `maxamount`   decimal(12,2) NOT NULL,
  PRIMARY KEY (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `loantype` (type, description, maxmonths, minamount, maxamount) VALUES
  ('SMALL', 'Väikelaen, lühiajaline',            12,  100.00,   5000.00),
  ('CONS',  'Tarbimislaen',                      12,  500.00,  10000.00),
  ('OVERDR','Arvelduskrediit (overdraft)',       12,   50.00,   3000.00);

-- Laen ise. Üks laen kuulub ühele kliendile ja makstakse välja ühele kontole.
CREATE TABLE `loan` (
  `loanid`         bigint unsigned NOT NULL AUTO_INCREMENT,
  `customerid`     bigint unsigned NOT NULL,
  `accountnumber`  bigint unsigned NOT NULL,        -- konto, kuhu laen välja makstakse
  `loantype`       char(6)         NOT NULL,
  `principal`      decimal(12,2)   NOT NULL,        -- väljamakstud põhiosa
  `interestrate`   decimal(5,2)    NOT NULL,        -- aastane intress protsentides
  `months`         smallint unsigned NOT NULL,      -- tähtaeg kuudes
  -- Graafiku tüüp. Just see otsustab, kuidas makse kuude vahel jaguneb:
  --   ANNUITY = annuiteet, igakuine makse on kogu aeg ühesugune
  --   FIXED   = fikseeritud põhiosa, makse väheneb kuust kuusse
  --   BULLET  = kogu põhiosa korraga lõpus, vahepeal ainult intress
  `scheduletype`   enum('ANNUITY','FIXED','BULLET') NOT NULL DEFAULT 'ANNUITY',
  `startdate`      date            NOT NULL,
  `enddate`        date            NOT NULL,
  `status`         enum('NEW','ACTIVE','CLOSED','OVERDUE') NOT NULL DEFAULT 'NEW',
  `createdat`      datetime        NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `closedat`       datetime        DEFAULT NULL,    -- NULL = laen ei ole veel lõppenud
  PRIMARY KEY (`loanid`),
  KEY `loan_customer` (`customerid`),
  KEY `loan_account`  (`accountnumber`),
  KEY `loan_type`     (`loantype`),
  KEY `loan_status`   (`status`),
  CONSTRAINT `loan_ibfk_1` FOREIGN KEY (`customerid`)    REFERENCES `customer` (`idcode`),
  CONSTRAINT `loan_ibfk_2` FOREIGN KEY (`accountnumber`) REFERENCES `account`  (`accountnumber`),
  CONSTRAINT `loan_ibfk_3` FOREIGN KEY (`loantype`)      REFERENCES `loantype` (`type`),
  CONSTRAINT `chk_loan_principal` CHECK (`principal` > 0),
  CONSTRAINT `chk_loan_rate`      CHECK (`interestrate` >= 0 AND `interestrate` <= 100),
  CONSTRAINT `chk_loan_months`    CHECK (`months` BETWEEN 1 AND 12),
  CONSTRAINT `chk_loan_dates`     CHECK (`enddate` > `startdate`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Maksegraafik: üks rida ühe makse kohta.
CREATE TABLE `loanschedule` (
  `id`              bigint unsigned NOT NULL AUTO_INCREMENT,
  `loanid`          bigint unsigned NOT NULL,
  `paymentno`       smallint unsigned NOT NULL,     -- 1, 2, 3 ...
  `duedate`         date          NOT NULL,         -- maksepäev (alati äripäev, vt dates)
  `principalamount` decimal(12,2) NOT NULL,
  `interestamount`  decimal(12,2) NOT NULL,
  `totalamount`     decimal(12,2) NOT NULL,
  `balanceafter`    decimal(12,2) NOT NULL,         -- jääk peale seda makset
  `ispaid`          tinyint(1)    NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_schedule` (`loanid`,`paymentno`),
  KEY `schedule_due` (`duedate`),
  CONSTRAINT `loanschedule_ibfk_1` FOREIGN KEY (`loanid`) REFERENCES `loan` (`loanid`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Tegelikult laekunud maksed. Eraldi graafikust, sest klient võib maksta
-- hiljem, osade kaupa või rohkem kui graafikus.
CREATE TABLE `loanpayment` (
  `id`            bigint unsigned NOT NULL AUTO_INCREMENT,
  `loanid`        bigint unsigned NOT NULL,
  `scheduleid`    bigint unsigned DEFAULT NULL,     -- NULL = ennetähtaegne makse
  `paymentdate`   date          NOT NULL,
  `amount`        decimal(12,2) NOT NULL,
  `transactionid` bigint unsigned DEFAULT NULL,     -- viide transaction tabelile
  PRIMARY KEY (`id`),
  KEY `payment_loan` (`loanid`),
  KEY `payment_date` (`paymentdate`),
  CONSTRAINT `loanpayment_ibfk_1` FOREIGN KEY (`loanid`)     REFERENCES `loan` (`loanid`),
  CONSTRAINT `loanpayment_ibfk_2` FOREIGN KEY (`scheduleid`) REFERENCES `loanschedule` (`id`),
  CONSTRAINT `chk_payment_amount` CHECK (`amount` > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 2. DATES - pangapäevade kalender
-- ---------------------------------------------------------------------
-- Pangapäev ei lange kokku kalendripäevaga: nädalavahetusel ja riigipühal
-- pank makseid ei töötle. Seepärast on eraldi tabel, kust saab küsida
-- "kas see päev on äripäev" ja "mis on järgmine äripäev".

DROP TABLE IF EXISTS `dates`;
CREATE TABLE `dates` (
  `id`           bigint unsigned NOT NULL AUTO_INCREMENT,
  `calendardate` date        NOT NULL,
  `daytype`      char(1)     NOT NULL,              -- B = business, H = holiday
  `note`         varchar(64) DEFAULT NULL,          -- NULL = tavaline äripäev
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_dates_date` (`calendardate`),
  KEY `idx_dates_type` (`daytype`,`calendardate`),
  CONSTRAINT `chk_daytype` CHECK (`daytype` IN ('B','H'))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- ---------------------------------------------------------------------
-- 3. CONFIG - key-value parameetrid
-- ---------------------------------------------------------------------
-- Kolm eraldi väärtusevälja, et ei peaks kuupäeva ega numbrit tekstina
-- hoidma: datavalue (tekst), datenum (arv), datechar (kuupäev).

DROP TABLE IF EXISTS `config`;
CREATE TABLE `config` (
  `confkey`    varchar(64)   NOT NULL,
  `datavalue`  varchar(255)  DEFAULT NULL,
  `datenum`    decimal(18,4) DEFAULT NULL,
  `datechar`   date          DEFAULT NULL,
  `description` varchar(255) DEFAULT NULL,
  `updatedat`  datetime      NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`confkey`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `config` (confkey, datavalue, datenum, datechar, description) VALUES
  ('KP',         NULL,        NULL, '2026-04-02', 'Pangapäev - kuupäev, mille seisuga pank praegu töötab'),
  ('NAME',       'Meie Pank', NULL,  NULL,        'Panga nimi'),
  ('PANGAKOOD',  NULL,        66,    NULL,        'Panga kood');

-- --- dates sisu: 365 rida 2026. aasta kohta ---
-- dates: 365 rida, B = 252, H = 113
INSERT INTO dates (calendardate, daytype, note) VALUES
  ('2026-01-01','H','uusaasta'), ('2026-01-02','B',NULL), ('2026-01-03','H','nädalavahetus'), ('2026-01-04','H','nädalavahetus'),
  ('2026-01-05','B',NULL), ('2026-01-06','B',NULL), ('2026-01-07','B',NULL), ('2026-01-08','B',NULL),
  ('2026-01-09','B',NULL), ('2026-01-10','H','nädalavahetus'), ('2026-01-11','H','nädalavahetus'), ('2026-01-12','B',NULL),
  ('2026-01-13','B',NULL), ('2026-01-14','B',NULL), ('2026-01-15','B',NULL), ('2026-01-16','B',NULL),
  ('2026-01-17','H','nädalavahetus'), ('2026-01-18','H','nädalavahetus'), ('2026-01-19','B',NULL), ('2026-01-20','B',NULL),
  ('2026-01-21','B',NULL), ('2026-01-22','B',NULL), ('2026-01-23','B',NULL), ('2026-01-24','H','nädalavahetus'),
  ('2026-01-25','H','nädalavahetus'), ('2026-01-26','B',NULL), ('2026-01-27','B',NULL), ('2026-01-28','B',NULL),
  ('2026-01-29','B',NULL), ('2026-01-30','B',NULL), ('2026-01-31','H','nädalavahetus'), ('2026-02-01','H','nädalavahetus'),
  ('2026-02-02','B',NULL), ('2026-02-03','B',NULL), ('2026-02-04','B',NULL), ('2026-02-05','B',NULL),
  ('2026-02-06','B',NULL), ('2026-02-07','H','nädalavahetus'), ('2026-02-08','H','nädalavahetus'), ('2026-02-09','B',NULL),
  ('2026-02-10','B',NULL), ('2026-02-11','B',NULL), ('2026-02-12','B',NULL), ('2026-02-13','B',NULL),
  ('2026-02-14','H','nädalavahetus'), ('2026-02-15','H','nädalavahetus'), ('2026-02-16','B',NULL), ('2026-02-17','B',NULL),
  ('2026-02-18','B',NULL), ('2026-02-19','B',NULL), ('2026-02-20','B',NULL), ('2026-02-21','H','nädalavahetus'),
  ('2026-02-22','H','nädalavahetus'), ('2026-02-23','B',NULL), ('2026-02-24','H','iseseisvuspäev'), ('2026-02-25','B',NULL),
  ('2026-02-26','B',NULL), ('2026-02-27','B',NULL), ('2026-02-28','H','nädalavahetus'), ('2026-03-01','H','nädalavahetus'),
  ('2026-03-02','B',NULL), ('2026-03-03','B',NULL), ('2026-03-04','B',NULL), ('2026-03-05','B',NULL),
  ('2026-03-06','B',NULL), ('2026-03-07','H','nädalavahetus'), ('2026-03-08','H','nädalavahetus'), ('2026-03-09','B',NULL),
  ('2026-03-10','B',NULL), ('2026-03-11','B',NULL), ('2026-03-12','B',NULL), ('2026-03-13','B',NULL),
  ('2026-03-14','H','nädalavahetus'), ('2026-03-15','H','nädalavahetus'), ('2026-03-16','B',NULL), ('2026-03-17','B',NULL),
  ('2026-03-18','B',NULL), ('2026-03-19','B',NULL), ('2026-03-20','B',NULL), ('2026-03-21','H','nädalavahetus'),
  ('2026-03-22','H','nädalavahetus'), ('2026-03-23','B',NULL), ('2026-03-24','B',NULL), ('2026-03-25','B',NULL),
  ('2026-03-26','B',NULL), ('2026-03-27','B',NULL), ('2026-03-28','H','nädalavahetus'), ('2026-03-29','H','nädalavahetus'),
  ('2026-03-30','B',NULL), ('2026-03-31','B',NULL), ('2026-04-01','B',NULL), ('2026-04-02','B',NULL),
  ('2026-04-03','H','suur reede'), ('2026-04-04','H','nädalavahetus'), ('2026-04-05','H','ülestõusmispühade 1. püha'), ('2026-04-06','B',NULL),
  ('2026-04-07','B',NULL), ('2026-04-08','B',NULL), ('2026-04-09','B',NULL), ('2026-04-10','B',NULL),
  ('2026-04-11','H','nädalavahetus'), ('2026-04-12','H','nädalavahetus'), ('2026-04-13','B',NULL), ('2026-04-14','B',NULL),
  ('2026-04-15','B',NULL), ('2026-04-16','B',NULL), ('2026-04-17','B',NULL), ('2026-04-18','H','nädalavahetus'),
  ('2026-04-19','H','nädalavahetus'), ('2026-04-20','B',NULL), ('2026-04-21','B',NULL), ('2026-04-22','B',NULL),
  ('2026-04-23','B',NULL), ('2026-04-24','B',NULL), ('2026-04-25','H','nädalavahetus'), ('2026-04-26','H','nädalavahetus'),
  ('2026-04-27','B',NULL), ('2026-04-28','B',NULL), ('2026-04-29','B',NULL), ('2026-04-30','B',NULL),
  ('2026-05-01','H','kevadpüha'), ('2026-05-02','H','nädalavahetus'), ('2026-05-03','H','nädalavahetus'), ('2026-05-04','B',NULL),
  ('2026-05-05','B',NULL), ('2026-05-06','B',NULL), ('2026-05-07','B',NULL), ('2026-05-08','B',NULL),
  ('2026-05-09','H','nädalavahetus'), ('2026-05-10','H','nädalavahetus'), ('2026-05-11','B',NULL), ('2026-05-12','B',NULL),
  ('2026-05-13','B',NULL), ('2026-05-14','B',NULL), ('2026-05-15','B',NULL), ('2026-05-16','H','nädalavahetus'),
  ('2026-05-17','H','nädalavahetus'), ('2026-05-18','B',NULL), ('2026-05-19','B',NULL), ('2026-05-20','B',NULL),
  ('2026-05-21','B',NULL), ('2026-05-22','B',NULL), ('2026-05-23','H','nädalavahetus'), ('2026-05-24','H','nelipühade 1. püha'),
  ('2026-05-25','B',NULL), ('2026-05-26','B',NULL), ('2026-05-27','B',NULL), ('2026-05-28','B',NULL),
  ('2026-05-29','B',NULL), ('2026-05-30','H','nädalavahetus'), ('2026-05-31','H','nädalavahetus'), ('2026-06-01','B',NULL),
  ('2026-06-02','B',NULL), ('2026-06-03','B',NULL), ('2026-06-04','B',NULL), ('2026-06-05','B',NULL),
  ('2026-06-06','H','nädalavahetus'), ('2026-06-07','H','nädalavahetus'), ('2026-06-08','B',NULL), ('2026-06-09','B',NULL),
  ('2026-06-10','B',NULL), ('2026-06-11','B',NULL), ('2026-06-12','B',NULL), ('2026-06-13','H','nädalavahetus'),
  ('2026-06-14','H','nädalavahetus'), ('2026-06-15','B',NULL), ('2026-06-16','B',NULL), ('2026-06-17','B',NULL),
  ('2026-06-18','B',NULL), ('2026-06-19','B',NULL), ('2026-06-20','H','nädalavahetus'), ('2026-06-21','H','nädalavahetus'),
  ('2026-06-22','B',NULL), ('2026-06-23','H','võidupüha'), ('2026-06-24','H','jaanipäev'), ('2026-06-25','B',NULL),
  ('2026-06-26','B',NULL), ('2026-06-27','H','nädalavahetus'), ('2026-06-28','H','nädalavahetus'), ('2026-06-29','B',NULL),
  ('2026-06-30','B',NULL), ('2026-07-01','B',NULL), ('2026-07-02','B',NULL), ('2026-07-03','B',NULL),
  ('2026-07-04','H','nädalavahetus'), ('2026-07-05','H','nädalavahetus'), ('2026-07-06','B',NULL), ('2026-07-07','B',NULL),
  ('2026-07-08','B',NULL), ('2026-07-09','B',NULL), ('2026-07-10','B',NULL), ('2026-07-11','H','nädalavahetus'),
  ('2026-07-12','H','nädalavahetus'), ('2026-07-13','B',NULL), ('2026-07-14','B',NULL), ('2026-07-15','B',NULL),
  ('2026-07-16','B',NULL), ('2026-07-17','B',NULL), ('2026-07-18','H','nädalavahetus'), ('2026-07-19','H','nädalavahetus'),
  ('2026-07-20','B',NULL), ('2026-07-21','B',NULL), ('2026-07-22','B',NULL), ('2026-07-23','B',NULL),
  ('2026-07-24','B',NULL), ('2026-07-25','H','nädalavahetus'), ('2026-07-26','H','nädalavahetus'), ('2026-07-27','B',NULL),
  ('2026-07-28','B',NULL), ('2026-07-29','B',NULL), ('2026-07-30','B',NULL), ('2026-07-31','B',NULL),
  ('2026-08-01','H','nädalavahetus'), ('2026-08-02','H','nädalavahetus'), ('2026-08-03','B',NULL), ('2026-08-04','B',NULL),
  ('2026-08-05','B',NULL), ('2026-08-06','B',NULL), ('2026-08-07','B',NULL), ('2026-08-08','H','nädalavahetus'),
  ('2026-08-09','H','nädalavahetus'), ('2026-08-10','B',NULL), ('2026-08-11','B',NULL), ('2026-08-12','B',NULL),
  ('2026-08-13','B',NULL), ('2026-08-14','B',NULL), ('2026-08-15','H','nädalavahetus'), ('2026-08-16','H','nädalavahetus'),
  ('2026-08-17','B',NULL), ('2026-08-18','B',NULL), ('2026-08-19','B',NULL), ('2026-08-20','H','taasiseseisvumispäev'),
  ('2026-08-21','B',NULL), ('2026-08-22','H','nädalavahetus'), ('2026-08-23','H','nädalavahetus'), ('2026-08-24','B',NULL),
  ('2026-08-25','B',NULL), ('2026-08-26','B',NULL), ('2026-08-27','B',NULL), ('2026-08-28','B',NULL),
  ('2026-08-29','H','nädalavahetus'), ('2026-08-30','H','nädalavahetus'), ('2026-08-31','B',NULL), ('2026-09-01','B',NULL),
  ('2026-09-02','B',NULL), ('2026-09-03','B',NULL), ('2026-09-04','B',NULL), ('2026-09-05','H','nädalavahetus'),
  ('2026-09-06','H','nädalavahetus'), ('2026-09-07','B',NULL), ('2026-09-08','B',NULL), ('2026-09-09','B',NULL),
  ('2026-09-10','B',NULL), ('2026-09-11','B',NULL), ('2026-09-12','H','nädalavahetus'), ('2026-09-13','H','nädalavahetus'),
  ('2026-09-14','B',NULL), ('2026-09-15','B',NULL), ('2026-09-16','B',NULL), ('2026-09-17','B',NULL),
  ('2026-09-18','B',NULL), ('2026-09-19','H','nädalavahetus'), ('2026-09-20','H','nädalavahetus'), ('2026-09-21','B',NULL),
  ('2026-09-22','B',NULL), ('2026-09-23','B',NULL), ('2026-09-24','B',NULL), ('2026-09-25','B',NULL),
  ('2026-09-26','H','nädalavahetus'), ('2026-09-27','H','nädalavahetus'), ('2026-09-28','B',NULL), ('2026-09-29','B',NULL),
  ('2026-09-30','B',NULL), ('2026-10-01','B',NULL), ('2026-10-02','B',NULL), ('2026-10-03','H','nädalavahetus'),
  ('2026-10-04','H','nädalavahetus'), ('2026-10-05','B',NULL), ('2026-10-06','B',NULL), ('2026-10-07','B',NULL),
  ('2026-10-08','B',NULL), ('2026-10-09','B',NULL), ('2026-10-10','H','nädalavahetus'), ('2026-10-11','H','nädalavahetus'),
  ('2026-10-12','B',NULL), ('2026-10-13','B',NULL), ('2026-10-14','B',NULL), ('2026-10-15','B',NULL),
  ('2026-10-16','B',NULL), ('2026-10-17','H','nädalavahetus'), ('2026-10-18','H','nädalavahetus'), ('2026-10-19','B',NULL),
  ('2026-10-20','B',NULL), ('2026-10-21','B',NULL), ('2026-10-22','B',NULL), ('2026-10-23','B',NULL),
  ('2026-10-24','H','nädalavahetus'), ('2026-10-25','H','nädalavahetus'), ('2026-10-26','B',NULL), ('2026-10-27','B',NULL),
  ('2026-10-28','B',NULL), ('2026-10-29','B',NULL), ('2026-10-30','B',NULL), ('2026-10-31','H','nädalavahetus'),
  ('2026-11-01','H','nädalavahetus'), ('2026-11-02','B',NULL), ('2026-11-03','B',NULL), ('2026-11-04','B',NULL),
  ('2026-11-05','B',NULL), ('2026-11-06','B',NULL), ('2026-11-07','H','nädalavahetus'), ('2026-11-08','H','nädalavahetus'),
  ('2026-11-09','B',NULL), ('2026-11-10','B',NULL), ('2026-11-11','B',NULL), ('2026-11-12','B',NULL),
  ('2026-11-13','B',NULL), ('2026-11-14','H','nädalavahetus'), ('2026-11-15','H','nädalavahetus'), ('2026-11-16','B',NULL),
  ('2026-11-17','B',NULL), ('2026-11-18','B',NULL), ('2026-11-19','B',NULL), ('2026-11-20','B',NULL),
  ('2026-11-21','H','nädalavahetus'), ('2026-11-22','H','nädalavahetus'), ('2026-11-23','B',NULL), ('2026-11-24','B',NULL),
  ('2026-11-25','B',NULL), ('2026-11-26','B',NULL), ('2026-11-27','B',NULL), ('2026-11-28','H','nädalavahetus'),
  ('2026-11-29','H','nädalavahetus'), ('2026-11-30','B',NULL), ('2026-12-01','B',NULL), ('2026-12-02','B',NULL),
  ('2026-12-03','B',NULL), ('2026-12-04','B',NULL), ('2026-12-05','H','nädalavahetus'), ('2026-12-06','H','nädalavahetus'),
  ('2026-12-07','B',NULL), ('2026-12-08','B',NULL), ('2026-12-09','B',NULL), ('2026-12-10','B',NULL),
  ('2026-12-11','B',NULL), ('2026-12-12','H','nädalavahetus'), ('2026-12-13','H','nädalavahetus'), ('2026-12-14','B',NULL),
  ('2026-12-15','B',NULL), ('2026-12-16','B',NULL), ('2026-12-17','B',NULL), ('2026-12-18','B',NULL),
  ('2026-12-19','H','nädalavahetus'), ('2026-12-20','H','nädalavahetus'), ('2026-12-21','B',NULL), ('2026-12-22','B',NULL),
  ('2026-12-23','B',NULL), ('2026-12-24','H','jõululaupäev'), ('2026-12-25','H','esimene jõulupüha'), ('2026-12-26','H','teine jõulupüha'),
  ('2026-12-27','H','nädalavahetus'), ('2026-12-28','B',NULL), ('2026-12-29','B',NULL), ('2026-12-30','B',NULL),
  ('2026-12-31','B',NULL);

-- =====================================================================
-- TA24Bbank - funktsioonid ja protseduurid
-- Jegor Onoprijuk, TA-24B
-- =====================================================================

DROP FUNCTION IF EXISTS is_business_day;
DROP FUNCTION IF EXISTS next_business_day;
DROP FUNCTION IF EXISTS add_business_days;
DROP FUNCTION IF EXISTS get_banking_day;
DROP PROCEDURE IF EXISTS next_banking_day;
DROP PROCEDURE IF EXISTS generate_loan_schedule;
DROP PROCEDURE IF EXISTS grant_loan;

DELIMITER $$

-- ---------------------------------------------------------------------
-- Kas antud kuupäev on äripäev? Vastus tuleb dates-tabelist.
-- Kui kuupäeva tabelis ei ole, tagastan NULL - nii on kohe näha, et
-- kalender on puudu, mitte et päev oleks puhkepäev.
-- ---------------------------------------------------------------------
CREATE FUNCTION is_business_day(p_date DATE)
RETURNS TINYINT(1)
READS SQL DATA
BEGIN
    DECLARE v_type CHAR(1);
    SELECT daytype INTO v_type FROM dates WHERE calendardate = p_date;
    IF v_type IS NULL THEN
        RETURN NULL;
    END IF;
    RETURN IF(v_type = 'B', 1, 0);
END$$

-- ---------------------------------------------------------------------
-- Järgmine äripäev antud kuupäeva järel.
-- Reedest saab esmaspäev, 23. juunist (võidupüha) saab 25. juuni jne.
-- ---------------------------------------------------------------------
CREATE FUNCTION next_business_day(p_date DATE)
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE v_next DATE;
    SELECT MIN(calendardate) INTO v_next
      FROM dates
     WHERE calendardate > p_date
       AND daytype = 'B';
    RETURN v_next;
END$$

-- ---------------------------------------------------------------------
-- Liida kuupäevale n äripäeva (n >= 0).
-- ---------------------------------------------------------------------
CREATE FUNCTION add_business_days(p_date DATE, p_n INT)
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE v_date DATE DEFAULT p_date;
    DECLARE i INT DEFAULT 0;
    WHILE i < p_n DO
        SET v_date = next_business_day(v_date);
        IF v_date IS NULL THEN
            RETURN NULL;                       -- kalender sai otsa
        END IF;
        SET i = i + 1;
    END WHILE;
    RETURN v_date;
END$$

-- ---------------------------------------------------------------------
-- Praegune pangapäev config-tabelist.
-- ---------------------------------------------------------------------
CREATE FUNCTION get_banking_day()
RETURNS DATE
READS SQL DATA
BEGIN
    DECLARE v_kp DATE;
    SELECT datechar INTO v_kp FROM config WHERE confkey = 'KP';
    RETURN v_kp;
END$$

-- ---------------------------------------------------------------------
-- PÕHIPROTSEDUUR: nihuta pangapäev ühe äripäeva võrra edasi.
-- Reedelt saab esmaspäev, pühade-eelsest päevast järgmine tööpäev.
-- Kirjutab tehtu ka log-tabelisse, et hiljem oleks näha, millal päev vahetus.
-- ---------------------------------------------------------------------
CREATE PROCEDURE next_banking_day()
BEGIN
    DECLARE v_old DATE;
    DECLARE v_new DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO log (message)
        VALUES (CONCAT('next_banking_day ERROR ', @errno, ' (', @sqlstate, ') ', @text));
    END;

    START TRANSACTION;

    SET v_old = get_banking_day();

    IF v_old IS NULL THEN
        INSERT INTO log (message) VALUES ('next_banking_day: config.KP puudub');
        ROLLBACK;
    ELSE
        SET v_new = next_business_day(v_old);

        IF v_new IS NULL THEN
            INSERT INTO log (message)
            VALUES (CONCAT('next_banking_day: kalendris ei ole ', v_old, ' järel ühtegi äripäeva'));
            ROLLBACK;
        ELSE
            UPDATE config SET datechar = v_new WHERE confkey = 'KP';
            INSERT INTO log (message)
            VALUES (CONCAT('Pangapäev: ', v_old, ' -> ', v_new));
            COMMIT;
        END IF;
    END IF;
END$$

-- ---------------------------------------------------------------------
-- Maksegraafiku koostamine. Siin ongi vastus küsimusele, mis vahe on
-- annuiteedil ja fikseeritud põhiosal:
--
--   ANNUITY - igakuine MAKSE on sama suur. Alguses on suurem osa maksest
--             intress ja väike osa põhiosa; lõpu poole vastupidi.
--             Valem: A = P * i / (1 - (1+i)^-n), kus i on kuu intress.
--   FIXED   - igakuine PÕHIOSA on sama suur (P/n), intress arvutatakse
--             jäägilt, seega kogumakse väheneb iga kuuga.
--   BULLET  - vahepeal makstakse ainult intressi, kogu põhiosa korraga lõpus.
--
-- Annuiteediga maksab klient kokku rohkem intressi, sest põhiosa väheneb
-- aeglasemalt. Fikseeritud põhiosaga on esimesed maksed suuremad, aga
-- kokku jääb intressi vähemaks.
--
-- Maksepäev nihutatakse alati äripäevale (dates-tabeli järgi).
-- ---------------------------------------------------------------------
CREATE PROCEDURE generate_loan_schedule(IN p_loanid BIGINT UNSIGNED)
BEGIN
    DECLARE v_principal   DECIMAL(12,2);
    DECLARE v_rate        DECIMAL(5,2);
    DECLARE v_months      SMALLINT;
    DECLARE v_type        VARCHAR(10);
    DECLARE v_start       DATE;
    DECLARE v_i           DECIMAL(16,10);     -- kuu intressimäär
    DECLARE v_annuity     DECIMAL(16,6);
    DECLARE v_balance     DECIMAL(12,2);
    DECLARE v_n           SMALLINT DEFAULT 1;
    DECLARE v_due         DATE;
    DECLARE v_interest    DECIMAL(12,2);
    DECLARE v_princpart   DECIMAL(12,2);
    DECLARE v_total       DECIMAL(12,2);

    SELECT principal, interestrate, months, scheduletype, startdate
      INTO v_principal, v_rate, v_months, v_type, v_start
      FROM loan WHERE loanid = p_loanid;

    IF v_principal IS NULL THEN
        INSERT INTO log (message) VALUES (CONCAT('generate_loan_schedule: laenu ', p_loanid, ' ei ole'));
    ELSE
        DELETE FROM loanschedule WHERE loanid = p_loanid;

        SET v_i = v_rate / 100 / 12;
        SET v_balance = v_principal;

        IF v_type = 'ANNUITY' THEN
            IF v_i = 0 THEN
                SET v_annuity = v_principal / v_months;
            ELSE
                SET v_annuity = v_principal * v_i / (1 - POW(1 + v_i, -v_months));
            END IF;
        END IF;

        WHILE v_n <= v_months DO
            -- maksepäev: sama kuupäev n kuud hiljem, nihutatud äripäevale
            SET v_due = DATE_ADD(v_start, INTERVAL v_n MONTH);
            IF is_business_day(v_due) = 0 THEN
                SET v_due = next_business_day(v_due);
            END IF;

            SET v_interest = ROUND(v_balance * v_i, 2);

            IF v_type = 'ANNUITY' THEN
                SET v_total     = ROUND(v_annuity, 2);
                SET v_princpart = v_total - v_interest;
            ELSEIF v_type = 'FIXED' THEN
                SET v_princpart = ROUND(v_principal / v_months, 2);
                SET v_total     = v_princpart + v_interest;
            ELSE                                   -- BULLET
                SET v_princpart = IF(v_n = v_months, v_balance, 0.00);
                SET v_total     = v_princpart + v_interest;
            END IF;

            -- viimane makse: ümardamisvead lähevad viimasesse ritta,
            -- et jääk tuleks täpselt 0.00
            IF v_n = v_months THEN
                SET v_princpart = v_balance;
                SET v_total     = v_princpart + v_interest;
            END IF;

            SET v_balance = v_balance - v_princpart;

            INSERT INTO loanschedule
                (loanid, paymentno, duedate, principalamount, interestamount, totalamount, balanceafter)
            VALUES
                (p_loanid, v_n, v_due, v_princpart, v_interest, v_total, v_balance);

            SET v_n = v_n + 1;
        END WHILE;

        UPDATE loan SET status = 'ACTIVE' WHERE loanid = p_loanid;
        INSERT INTO log (message)
        VALUES (CONCAT('Laenule ', p_loanid, ' tehti graafik: ', v_months, ' makset, tüüp ', v_type));
    END IF;
END$$

-- ---------------------------------------------------------------------
-- Laenu väljastamine: kirje loan-tabelisse, raha kliendi kontole,
-- graafik valmis. Kõik ühe tehinguna.
-- ---------------------------------------------------------------------
CREATE PROCEDURE grant_loan(IN p_customerid BIGINT UNSIGNED,
                            IN p_accountnumber BIGINT UNSIGNED,
                            IN p_loantype CHAR(6),
                            IN p_principal DECIMAL(12,2),
                            IN p_rate DECIMAL(5,2),
                            IN p_months SMALLINT,
                            IN p_scheduletype VARCHAR(10))
BEGIN
    DECLARE v_loanid BIGINT UNSIGNED;
    DECLARE v_start  DATE;
    DECLARE v_end    DATE;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        GET DIAGNOSTICS CONDITION 1 @sqlstate = RETURNED_SQLSTATE,
            @errno = MYSQL_ERRNO, @text = MESSAGE_TEXT;
        ROLLBACK;
        INSERT INTO log (message)
        VALUES (CONCAT('grant_loan ERROR ', @errno, ' (', @sqlstate, ') ', @text));
    END;

    START TRANSACTION;

    SET v_start = get_banking_day();
    SET v_end   = DATE_ADD(v_start, INTERVAL p_months MONTH);

    INSERT INTO loan (customerid, accountnumber, loantype, principal, interestrate,
                      months, scheduletype, startdate, enddate, status)
    VALUES (p_customerid, p_accountnumber, p_loantype, p_principal, p_rate,
            p_months, p_scheduletype, v_start, v_end, 'NEW');

    SET v_loanid = LAST_INSERT_ID();

    -- raha kliendi kontole
    UPDATE account SET balance = balance + p_principal
     WHERE accountnumber = p_accountnumber;

    CALL generate_loan_schedule(v_loanid);

    INSERT INTO log (message)
    VALUES (CONCAT('Laen ', v_loanid, ' kliendile ', p_customerid, ': ', p_principal,
                   ' EUR, ', p_rate, '%, ', p_months, ' kuud (', p_scheduletype, ')'));

    COMMIT;
END$$

DELIMITER ;

-- =====================================================================
-- 5. NÄIDISKASUTUS JA KONTROLL
-- =====================================================================
-- Need laused ei ole kohustuslikud, aga nende abil sai kogu asi läbi
-- testitud. Kommentaarides on tulemused, mis mul päriselt välja tulid.

-- 5.1 Pangapäeva nihutamine -------------------------------------------
-- SELECT get_banking_day();            -- 2026-04-02 (neljapäev)
-- CALL next_banking_day();
-- SELECT get_banking_day();            -- 2026-04-06 (esmaspäev!)
--   Vahele jäid: 03.04 suur reede, 04.04 laupäev, 05.04 ülestõusmispühad.
-- CALL next_banking_day();  -- 2026-04-07
-- ...
-- Reedest 2026-04-10 sai 2026-04-13, ehk esmaspäev. Täpselt nagu nõutud.

-- 5.2 Kolm laenu, kolm graafikut ---------------------------------------
-- Sama laen (3000 EUR, 12% aastas, 6 kuud) kolmes erinevas vormis:
-- CALL grant_loan(37712212345, 100002, 'SMALL', 3000.00, 12.00, 6, 'ANNUITY');
-- CALL grant_loan(3678104569,  100003, 'CONS',  3000.00, 12.00, 6, 'FIXED');
-- CALL grant_loan(3678104572,  100004, 'SMALL', 3000.00, 12.00, 6, 'BULLET');

-- ANNUITY - makse on iga kuu ühesugune, aga sisu muutub:
--   nr  kuupäev     põhiosa  intress  makse    jääk
--   1   2026-05-04  487.65   30.00    517.65   2512.35
--   2   2026-06-02  492.53   25.12    517.65   2019.82
--   3   2026-07-02  497.45   20.20    517.65   1522.37
--   4   2026-08-03  502.43   15.22    517.65   1019.94
--   5   2026-09-02  507.45   10.20    517.65    512.49
--   6   2026-10-02  512.49    5.12    517.61      0.00
--   intressi kokku 105.86

-- FIXED - põhiosa on iga kuu 500, makse väheneb:
--   1   2026-05-04  500.00   30.00    530.00   2500.00
--   2   2026-06-02  500.00   25.00    525.00   2000.00
--   3   2026-07-02  500.00   20.00    520.00   1500.00
--   4   2026-08-03  500.00   15.00    515.00   1000.00
--   5   2026-09-02  500.00   10.00    510.00    500.00
--   6   2026-10-02  500.00    5.00    505.00      0.00
--   intressi kokku 105.00

-- BULLET - vahepeal ainult intress, põhiosa lõpus:
--   1-5 2026-05-04..09-02   0.00   30.00     30.00  3000.00
--   6   2026-10-02       3000.00   30.00   3030.00     0.00
--   intressi kokku 180.00

-- Tähelepanu kuupäevadele: 2026-05-02 on laupäev ja 2026-08-02 pühapäev,
-- mõlemad nihkusid automaatselt järgmisele äripäevale (04.05 ja 03.08).

-- 5.3 Kontrollpäringud -------------------------------------------------

-- Kas kalender on täis ja õige?
SELECT daytype, COUNT(*) AS paevi FROM dates GROUP BY daytype;
--   B = 252, H = 113, kokku 365

-- Riigipühad eraldi
SELECT calendardate, DAYNAME(calendardate) AS nadalapaev, note
  FROM dates
 WHERE note IS NOT NULL AND note <> 'nädalavahetus'
 ORDER BY calendardate;

-- Panga parameetrid
SELECT confkey, datavalue, datenum, datechar FROM config;

-- Laenude kokkuvõte: kui palju intressi iga graafikutüüp maksma läheb
SELECT l.loanid, l.scheduletype,
       ROUND(SUM(s.interestamount), 2) AS intress_kokku,
       ROUND(SUM(s.totalamount), 2)    AS makseid_kokku
  FROM loan l
  JOIN loanschedule s ON s.loanid = l.loanid
 GROUP BY l.loanid, l.scheduletype
 ORDER BY l.loanid;

-- Kas kõik maksepäevad on äripäevad?
SELECT COUNT(*) AS maksed_puhkepaeval
  FROM loanschedule s
  JOIN dates d ON d.calendardate = s.duedate
 WHERE d.daytype = 'H';
--   peab tulema 0

-- Lähima nädala maksed (seda päringut kasutaks päris pank igal hommikul)
SELECT s.duedate, c.firstname, c.lastname, s.totalamount, l.scheduletype
  FROM loanschedule s
  JOIN loan l     ON l.loanid = s.loanid
  JOIN customer c ON c.idcode = l.customerid
 WHERE s.ispaid = 0
   AND s.duedate BETWEEN get_banking_day() AND add_business_days(get_banking_day(), 5)
 ORDER BY s.duedate;
