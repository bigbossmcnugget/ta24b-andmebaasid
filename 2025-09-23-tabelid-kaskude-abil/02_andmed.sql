USE tunniplaan;
INSERT INTO teacher VALUES ('T001','Timo','Triis'),('T002','Marju','Käsk'),('T003','Anna','Tamm'),('T004','Peeter','Kask');
INSERT INTO subject VALUES ('ANDM','Andmebaasid'),('OS','Operatsioonisüsteemid'),('PROG','Programmeerimise alused'),('JS','JavaScript'),('UI','Kasutajaliidese disain');
INSERT INTO studentgroup VALUES ('TA-24B','Tarkvaraarendus 24B'),('TA-24A','Tarkvaraarendus 24A'),('IT-24','Infotehnoloogia 24');
INSERT INTO student VALUES
  ('50601010001','Jegor','Onoprijuk'),
  ('50503020002','Mari','Maasikas'),
  ('50712120003','Karl','Kuusk'),
  ('50805050004','Liis','Lepik');
INSERT INTO enrollment VALUES ('50601010001','TA-24B'),('50503020002','TA-24B'),('50712120003','TA-24A'),('50805050004','IT-24');
INSERT INTO room VALUES ('A-309',24,24),('A-310',30,0),('B-101',16,16),('C-204',20,10);
INSERT INTO class (subjectcode, studentgroupcode, starttime, endtime, comments) VALUES
  ('ANDM','TA-24B','2025-09-23 08:30:00','2025-09-23 10:00:00','Tabelid käskude abil'),
  ('OS','TA-24B','2025-09-23 10:15:00','2025-09-23 11:45:00',NULL),
  ('PROG','TA-24A','2025-09-24 12:00:00','2025-09-24 13:30:00','Tsüklid'),
  ('JS','IT-24','2025-09-25 08:30:00','2025-09-25 10:00:00',NULL),
  ('UI',NULL,'2025-09-26 14:00:00','2025-09-26 15:30:00','Ühine loeng');
INSERT INTO grade (studentidcode, subjectcode, grade, time) VALUES
  ('50601010001','ANDM',5,'2025-09-23 10:05:00'),
  ('50601010001','OS',4,'2025-09-23 11:50:00');
INSERT INTO grade (studentidcode, subjectcode, grade) VALUES   -- time jaab vaikeväärtusele (praegune hetk)
  ('50503020002','ANDM',4),
  ('50712120003','PROG',3),
  ('50805050004','JS',5);
