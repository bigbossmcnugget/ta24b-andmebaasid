-- =====================================================================
--  Testid - 2026-02-26 Triggers, procedures
--  Jegor Onoprijuk, ruhm TA-24B
-- =====================================================================
USE TA24Bbank_trig;

SELECT USER() AS uhendus_kasutajaga, DATABASE() AS andmebaas;

-- --- 1. ulesande oma naide: Anna Kask ---------------------------------
SELECT '--- 1. INSERT customer (ulesande naide: Anna Kask)' AS samm;
INSERT INTO customer (idcode, firstname, lastname, address, email, customertype)
VALUES (48701022321, 'Anna', 'Kask', 'Tartu', 'anna@hotmail.com', 'BASIC');

-- --- 2. mina ise klient + konto -------------------------------------
SELECT '--- 2. Jegor Onoprijuk lisatud kliendina (protseduur add_customer_with_account)' AS samm;
CALL add_customer_with_account(50603142719, 'Jegor', 'Onoprijuk',
     'jegor.onoprijuk@example.com', 'OURS', 100100, 2500.00);

SELECT '--- 3. veel mitu klienti' AS samm;
INSERT INTO customer (idcode, firstname, lastname, address, email, customertype) VALUES
  (39001010011, 'Mari',   'Tamm',   'Tallinn', 'mari.tamm@example.com',   'SILVER'),
  (38505050022, 'Jaan',   'Kask',   'Parnu',   'jaan.kask@example.com',   'GOLD'),
  (49203030033, 'Liis',   'Saar',   'Viljandi','liis.saar@example.com',   'BASIC'),
  (37707070044, 'Peeter', 'Lepik',  'Rakvere', 'peeter.lepik@example.com','BRONZE');

INSERT INTO account (accountnumber, accounttype, customerid, balance) VALUES
  (100000, 'EQUITY', 10000, -10000000),
  (100001, 'CASH',   10000,  10000000),
  (100101, 'CURR', 39001010011, 1200.00),
  (100102, 'CURR', 38505050022, 8800.50);

-- --- 2. UPDATE -----------------------------------------------------------
SELECT '--- 4. UPDATE: Anna muudab e-posti, Mari saab GOLD-kliendiks' AS samm;
UPDATE customer SET email = 'anna@gmail.com' WHERE idcode = 48701022321;
UPDATE customer SET customertype = 'GOLD'    WHERE idcode = 39001010011;
UPDATE account  SET balance = balance + 300  WHERE accountnumber = 100101;

-- --- 3. DELETE -----------------------------------------------------------
SELECT '--- 5. DELETE: Peeter Lepik kustutatakse' AS samm;
DELETE FROM customer WHERE idcode = 37707070044;

-- --- audit ---------------------------------------------------------------
SELECT '--- 6. AUDIT (koik, mis tehtud)' AS samm;
SELECT id, tablename, tableid, operation, user, audittime FROM audit ORDER BY id;

SELECT '--- 7. VAADE audit_kokkuvote' AS samm;
SELECT * FROM audit_kokkuvote;

SELECT '--- 8. protseduur audit_history: Jegor Onoprijuk' AS samm;
CALL audit_history(50603142719);

SELECT '--- 9. protseduur audit_history: Mari Tamm (UPD customer + UPD account)' AS samm;
CALL audit_history(39001010011);

-- --- tehing: eba onnestunud lisamine ei jata pooleli klienti -----------
SELECT '--- 10. katsetus: sama e-post teist korda - protseduur peab ROLLBACK-ima' AS samm;
SELECT COUNT(*) AS kliente_enne FROM customer;
-- (viga on meelega; katkestab skripti, seega kasitleme eraldi kliendiga)
