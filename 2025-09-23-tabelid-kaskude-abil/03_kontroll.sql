USE tunniplaan;
SHOW TABLES;
SELECT * FROM student;
SELECT s.firstname, s.lastname, e.studentgroupcode FROM student s JOIN enrollment e ON e.studentidcode = s.idcode;
SELECT * FROM class;
SELECT * FROM room;
SELECT * FROM grade;
-- vigaste andmete testid: need PEAVAD ebaõnnestuma
INSERT INTO class (subjectcode, studentgroupcode, starttime, endtime) VALUES ('ANDM','TA-24B','2025-09-30 10:00:00','2025-09-30 09:00:00');
INSERT INTO grade (studentidcode, subjectcode, grade) VALUES ('50601010001','JS',6);
