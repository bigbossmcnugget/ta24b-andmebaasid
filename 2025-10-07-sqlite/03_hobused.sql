-- B2: lihtne SQLite andmebaas hobuste, omanike ja tallide kohta   Jegor Onoprijuk, TA-24B
PRAGMA foreign_keys = ON;
DROP TABLE IF EXISTS hobune; DROP TABLE IF EXISTS omanik; DROP TABLE IF EXISTS tall;

CREATE TABLE tall (                       -- tall = stable
  tallikood TEXT PRIMARY KEY,
  aadress   TEXT NOT NULL
);
CREATE TABLE omanik (                     -- omaniku kohta: kood, nimi, aadress, telefon, tall
  omanikukood INTEGER PRIMARY KEY,
  nimi        TEXT NOT NULL,
  aadress     TEXT NOT NULL,
  telefon     TEXT NOT NULL,
  tallikood   TEXT NOT NULL REFERENCES tall (tallikood)   -- omanikul on tall, tallis võib olla palju omanikke
);
CREATE TABLE hobune (                     -- iga hobuse kohta: registreerimiskood, nimi, sünniaasta, omanik, tall
  regkood     TEXT PRIMARY KEY,
  nimi        TEXT NOT NULL,
  synniaasta  INTEGER NOT NULL,
  omanikukood INTEGER NOT NULL REFERENCES omanik (omanikukood),  -- igal hobusel on üks omanik, omanikul võib olla mitu hobust
  tallikood   TEXT NOT NULL REFERENCES tall (tallikood)          -- iga hobune on täpselt ühes tallis
);

INSERT INTO tall VALUES ('T1','Tallinna mnt 12, Saue'),('T2','Pargi 5, Tartu'),('T3','Mäe tee 7, Pärnu'),('T4','Metsa 21, Viljandi');
INSERT INTO omanik VALUES
  (1,'Jegor Onoprijuk','Pargi 5, Tartu','+372 5551 0001','T2'),   -- mina ise omanikuna
  (2,'Mari Maasikas','Tallinna mnt 12, Saue','+372 5551 0002','T1'),
  (3,'Karl Kuusk','Mäe tee 7, Pärnu','+372 5551 0003','T3'),
  (4,'Liis Lepik','Metsa 21, Viljandi','+372 5551 0004','T4');
INSERT INTO hobune VALUES
  ('EE-0001','Tuuli',2015,1,'T2'),
  ('EE-0002','Pilvi',2018,1,'T2'),      -- minu teine hobune
  ('EE-0003','Kaarnakas',2012,2,'T1'),
  ('EE-0004','Välk',2020,3,'T3'),
  ('EE-0005','Kuld',2017,3,'T3'),
  ('EE-0006','Hall',2010,4,'T4');
