-- =====================================================================
--  2026-02-26  Triggers, procedures  -  TA24Bbank
--  Jegor Onoprijuk, ruhm TA-24B
--
--  Opetaja markus eelmise esituse kohta: "Saata tuleb dump. Siin vahe asju."
--  Seega see versioon on tehtud TAIELIKULT - oma andmebaas, koik triggerid,
--  protseduurid, testandmed ja terve dump (vt 02_TA24Bbank_trig_dump...sql).
--
--  Ulesande nouded:
--    * triggerid customer-tabelile (INS / UPD / DEL -> audit)
--    * oma koopia TA24Bbank dumpist
--  Mina tegin juurde:
--    * samad triggerid account-tabelile
--    * audit-paringud (vaade) ja protseduurid, mis neid kasutavad
--    * testid, mille valjund on salvestatud failis valjund.txt
-- =====================================================================

DROP DATABASE IF EXISTS TA24Bbank_trig;
CREATE DATABASE TA24Bbank_trig CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE TA24Bbank_trig;

-- ---------------------------------------------------------------- tabelid
CREATE TABLE customertype (
    type        CHAR(6)      PRIMARY KEY,
    description VARCHAR(64)  NOT NULL
);

INSERT INTO customertype (type, description) VALUES
  ('BASIC',  'Tavaklient'),
  ('BRONZE', 'Pronksklient'),
  ('SILVER', 'Hoberklient'),
  ('GOLD',   'Kuldklient'),
  ('OURS',   'Meie ise');

CREATE TABLE customer (
    idcode       BIGINT UNSIGNED PRIMARY KEY,
    firstname    VARCHAR(64)  NOT NULL,
    lastname     VARCHAR(64)  NOT NULL,
    address      VARCHAR(255),
    email        VARCHAR(64)  UNIQUE,
    customertype CHAR(6),
    phone        VARCHAR(32),
    gender       VARCHAR(8),
    FOREIGN KEY (customertype) REFERENCES customertype(type)
);

CREATE TABLE accounttype (
    type        CHAR(6)      PRIMARY KEY,
    description VARCHAR(255) NOT NULL
);

INSERT INTO accounttype (type, description) VALUES
  ('EQUITY', 'Omakapital'),
  ('CASH',   'Sularaha'),
  ('HLOAN',  'Kodulaen'),
  ('CURR',   'Arvelduskonto');

CREATE TABLE account (
    accountnumber BIGINT UNSIGNED PRIMARY KEY,
    accounttype   CHAR(6)          NOT NULL,
    customerid    BIGINT UNSIGNED  NOT NULL,
    currency      CHAR(3)          NOT NULL DEFAULT 'EUR',
    balance       DECIMAL(12,2)    NOT NULL,
    interestrate  DECIMAL(5,2)     DEFAULT 0 NOT NULL,
    FOREIGN KEY (accounttype) REFERENCES accounttype(type)
);

-- audit: kes, mida, millal muutis. Veerud on sellised nagu ulesandes ette antud
-- (tablename, tableid, operation, user) + audittime, mis tuleb ise.
CREATE TABLE audit (
    id        BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tablename VARCHAR(36),
    tableid   VARCHAR(36),
    operation CHAR(3),
    user      VARCHAR(64),
    audittime DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------- triggerid: customer (nouded)
DELIMITER //

CREATE TRIGGER after_customer_insert
AFTER INSERT ON customer
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('CUSTOMER', NEW.idcode, 'INS', USER());
END//

CREATE TRIGGER after_customer_update
AFTER UPDATE ON customer
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('CUSTOMER', NEW.idcode, 'UPD', USER());
END//

CREATE TRIGGER after_customer_delete
AFTER DELETE ON customer
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('CUSTOMER', OLD.idcode, 'DEL', USER());
END//

-- ------------------------------------ triggerid: account (minu lisatud osa)
CREATE TRIGGER after_account_insert
AFTER INSERT ON account
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('ACCOUNT', NEW.accountnumber, 'INS', USER());
END//

CREATE TRIGGER after_account_update
AFTER UPDATE ON account
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('ACCOUNT', NEW.accountnumber, 'UPD', USER());
END//

CREATE TRIGGER after_account_delete
AFTER DELETE ON account
FOR EACH ROW BEGIN
    INSERT INTO audit (tablename, tableid, operation, user)
    VALUES ('ACCOUNT', OLD.accountnumber, 'DEL', USER());
END//

DELIMITER ;

-- --------------------------------------------------- vaade audit-paringuteks
CREATE VIEW audit_kokkuvote AS
SELECT tablename                                AS tabel,
       SUM(operation = 'INS')                   AS lisatud,
       SUM(operation = 'UPD')                   AS muudetud,
       SUM(operation = 'DEL')                   AS kustutatud,
       COUNT(*)                                 AS kokku,
       MAX(audittime)                           AS viimane_muudatus
FROM audit
GROUP BY tablename;

-- ----------------------------------------------------------- protseduurid
DELIMITER //

-- klient + tema esimene konto uhe korraga (tehing: kui konto ebaonnestub,
-- ei jaa ka klient pooleli)
CREATE PROCEDURE add_customer_with_account(
    IN p_idcode BIGINT UNSIGNED, IN p_firstname VARCHAR(64), IN p_lastname VARCHAR(64),
    IN p_email VARCHAR(64), IN p_customertype CHAR(6),
    IN p_accountnumber BIGINT UNSIGNED, IN p_balance DECIMAL(12,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    INSERT INTO customer (idcode, firstname, lastname, email, customertype)
    VALUES (p_idcode, p_firstname, p_lastname, p_email, p_customertype);
    INSERT INTO account (accountnumber, accounttype, customerid, balance)
    VALUES (p_accountnumber, 'CURR', p_idcode, p_balance);
    COMMIT;
END//

-- kogu ajalugu uhe kirje kohta (nii customer kui tema kontod)
CREATE PROCEDURE audit_history(IN p_idcode BIGINT UNSIGNED)
BEGIN
    SELECT a.id, a.tablename, a.tableid, a.operation, a.user, a.audittime
    FROM audit a
    WHERE (a.tablename = 'CUSTOMER' AND a.tableid = p_idcode)
       OR (a.tablename = 'ACCOUNT'  AND a.tableid IN
              (SELECT accountnumber FROM account WHERE customerid = p_idcode))
    ORDER BY a.id;
END//

DELIMITER ;
