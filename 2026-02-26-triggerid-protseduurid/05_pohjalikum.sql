USE TA24Bbank_trig;
SELECT COUNT(*) AS kliente_parast FROM customer;
SELECT COUNT(*) AS tehtud_Test_klient FROM customer WHERE idcode = 30000000001;
SELECT COUNT(*) AS tehtud_konto_100999 FROM account WHERE accountnumber = 100999;
SELECT '-> ei klienti ega kontot: tehing rullus tagasi' AS tulemus;
SELECT TRIGGER_NAME, EVENT_MANIPULATION AS sundmus, EVENT_OBJECT_TABLE AS tabel, DEFINER
FROM information_schema.TRIGGERS WHERE TRIGGER_SCHEMA = 'TA24Bbank_trig' ORDER BY TRIGGER_NAME;
