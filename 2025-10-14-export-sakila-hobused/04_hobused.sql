-- III Hobuste andmebaas SQLite'is, 10 tabelit   Jegor Onoprijuk, TA-24B
PRAGMA foreign_keys = ON;
DROP TABLE IF EXISTS vaktsineerimine; DROP TABLE IF EXISTS tulemus; DROP TABLE IF EXISTS treening;
DROP TABLE IF EXISTS hobune; DROP TABLE IF EXISTS omanik; DROP TABLE IF EXISTS tall;
DROP TABLE IF EXISTS toug; DROP TABLE IF EXISTS treener; DROP TABLE IF EXISTS voistlus; DROP TABLE IF EXISTS veterinaar;

CREATE TABLE tall       (tallikood TEXT PRIMARY KEY, nimi TEXT NOT NULL, aadress TEXT NOT NULL);
CREATE TABLE toug       (tougkood INTEGER PRIMARY KEY, nimi TEXT NOT NULL UNIQUE);
CREATE TABLE omanik     (omanikukood INTEGER PRIMARY KEY, nimi TEXT NOT NULL, aadress TEXT NOT NULL, telefon TEXT NOT NULL,
                         tallikood TEXT NOT NULL REFERENCES tall (tallikood));
CREATE TABLE hobune     (regkood TEXT PRIMARY KEY, nimi TEXT NOT NULL, synniaasta INTEGER NOT NULL,
                         sugu TEXT NOT NULL CHECK (sugu IN ('mära','täkk','ruun')),
                         tougkood    INTEGER NOT NULL REFERENCES toug (tougkood),
                         omanikukood INTEGER NOT NULL REFERENCES omanik (omanikukood),
                         tallikood   TEXT    NOT NULL REFERENCES tall (tallikood));
CREATE TABLE treener    (treenerikood INTEGER PRIMARY KEY, nimi TEXT NOT NULL, telefon TEXT);
CREATE TABLE treening   (id INTEGER PRIMARY KEY AUTOINCREMENT,
                         regkood TEXT NOT NULL REFERENCES hobune (regkood),
                         treenerikood INTEGER NOT NULL REFERENCES treener (treenerikood),
                         kuupaev TEXT NOT NULL, kestus_min INTEGER NOT NULL CHECK (kestus_min > 0), kirjeldus TEXT);
CREATE TABLE voistlus   (id INTEGER PRIMARY KEY AUTOINCREMENT, nimi TEXT NOT NULL, kuupaev TEXT NOT NULL, koht TEXT NOT NULL);
CREATE TABLE tulemus    (voistlus_id INTEGER NOT NULL REFERENCES voistlus (id),
                         regkood TEXT NOT NULL REFERENCES hobune (regkood),
                         koht INTEGER NOT NULL CHECK (koht > 0), aeg_sek REAL,
                         PRIMARY KEY (voistlus_id, regkood));
CREATE TABLE veterinaar (vetkood INTEGER PRIMARY KEY, nimi TEXT NOT NULL, telefon TEXT);
CREATE TABLE vaktsineerimine (id INTEGER PRIMARY KEY AUTOINCREMENT,
                         regkood TEXT NOT NULL REFERENCES hobune (regkood),
                         vetkood INTEGER NOT NULL REFERENCES veterinaar (vetkood),
                         kuupaev TEXT NOT NULL, vaktsiin TEXT NOT NULL);

INSERT INTO tall VALUES ('T1','Saue Ratsakeskus','Tallinna mnt 12, Saue'),('T2','Tartu Ratsaklubi','Pargi 5, Tartu'),('T3','Pärnu Talu','Mäe tee 7, Pärnu'),('T4','Viljandi Tall','Metsa 21, Viljandi');
INSERT INTO toug VALUES (1,'Eesti raskeveohobune'),(2,'Eesti tõugu hobune'),(3,'Araabia täisverd'),(4,'Tori hobune');
INSERT INTO omanik VALUES (1,'Jegor Onoprijuk','Pargi 5, Tartu','+372 5551 0001','T2'),(2,'Mari Maasikas','Tallinna mnt 12, Saue','+372 5551 0002','T1'),
  (3,'Karl Kuusk','Mäe tee 7, Pärnu','+372 5551 0003','T3'),(4,'Liis Lepik','Metsa 21, Viljandi','+372 5551 0004','T4');
INSERT INTO hobune VALUES
  ('EE-0001','Tuuli',2015,'mära',2,1,'T2'),('EE-0002','Pilvi',2018,'mära',3,1,'T2'),('EE-0003','Kaarnakas',2012,'ruun',1,2,'T1'),
  ('EE-0004','Välk',2020,'täkk',3,3,'T3'),('EE-0005','Kuld',2017,'ruun',4,3,'T3'),('EE-0006','Hall',2010,'mära',2,4,'T4');
INSERT INTO treener VALUES (1,'Anna Tamm','+372 5552 0001'),(2,'Peeter Kask','+372 5552 0002'),(3,'Triin Mägi',NULL);
INSERT INTO treening (regkood,treenerikood,kuupaev,kestus_min,kirjeldus) VALUES
  ('EE-0001',1,'2025-10-01',45,'Põhikäigud'),('EE-0001',1,'2025-10-08',60,'Hüpped'),('EE-0002',2,'2025-10-02',30,'Longeerimine'),
  ('EE-0004',3,'2025-10-03',50,'Sprint'),('EE-0006',2,'2025-10-05',40,NULL);
INSERT INTO voistlus (nimi,kuupaev,koht) VALUES ('Sügisvõistlus','2025-09-28','Tartu'),('Pärnu Karikas','2025-10-12','Pärnu'),('Jõuluhüpped','2025-12-14','Tallinn');
INSERT INTO tulemus VALUES (1,'EE-0001',1,62.4),(1,'EE-0002',3,66.0),(1,'EE-0004',2,63.1),(2,'EE-0001',2,61.8),(2,'EE-0005',1,60.2),(2,'EE-0006',4,NULL);
INSERT INTO veterinaar VALUES (1,'Mihkel Vares','+372 5553 0001'),(2,'Kadri Saar','+372 5553 0002');
INSERT INTO vaktsineerimine (regkood,vetkood,kuupaev,vaktsiin) VALUES
  ('EE-0001',1,'2025-03-10','Gripp'),('EE-0001',1,'2025-09-10','Teetanus'),('EE-0002',2,'2025-03-12','Gripp'),('EE-0004',2,'2025-04-01','Gripp'),('EE-0006',1,'2025-05-20','Teetanus');
