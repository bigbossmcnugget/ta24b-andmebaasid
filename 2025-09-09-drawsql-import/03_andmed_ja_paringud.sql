INSERT INTO `Rühm` VALUES ('TA-24B','Tarkvaraarendus 24B'),('TA-24A','Tarkvaraarendus 24A'),('IT-24','Infotehnoloogia 24'),('KT-24','Küberturve 24');
INSERT INTO `Õppeaine` VALUES ('ANDM','Andmebaasid'),('OS','Operatsioonisüsteemid'),('PROG','Programmeerimise alused'),('JS','JavaScript');
INSERT INTO `Õpilane` VALUES
 (50601010001,'Jegor','Onoprijuk','2006-01-01','Tartu','+372 5551 0001','TA-24B'),
 (50503020002,'Mari','Maasikas','2005-03-02','Tallinn',NULL,'TA-24B'),
 (50712120003,'Karl','Kuusk','2007-12-12','Pärnu','+372 5551 0003','TA-24A'),
 (50805050004,'Liis','Lepik',  '2008-05-05',NULL,NULL,'IT-24');
INSERT INTO `Esindaja` VALUES (50601010001,'E001','Anna','Onoprijuk'),(50503020002,'E002','Peeter','Maasikas'),(50712120003,'E003','Kadri','Kuusk'),(50805050004,'E004','Tiit','Lepik');
INSERT INTO `Rühmaine` VALUES ('TA-24B','ANDM'),('TA-24B','OS'),('TA-24A','PROG'),('IT-24','JS'),('TA-24B','PROG');
-- päringud
SELECT r.kirjeldus AS ruhm, COUNT(o.idkood) AS opilasi FROM `Rühm` r LEFT JOIN `Õpilane` o ON o.rühmakood = r.kood GROUP BY r.kood ORDER BY opilasi DESC;
SELECT o.eesnimi, o.perekonnanimi, e.eesnimi AS esindaja FROM `Õpilane` o JOIN `Esindaja` e ON e.õpilaseidkood = o.idkood;
SELECT r.kood AS ruhm, GROUP_CONCAT(a.kirjeldus ORDER BY a.kirjeldus SEPARATOR ', ') AS ained FROM `Rühm` r JOIN `Rühmaine` ra ON ra.rühm = r.kood JOIN `Õppeaine` a ON a.kood = ra.aine GROUP BY r.kood;
