PRAGMA foreign_keys=OFF;
BEGIN TRANSACTION;
CREATE TABLE treener (
	id INTEGER NOT NULL, 
	eesnimi VARCHAR(50) NOT NULL, 
	perekonnanimi VARCHAR(50) NOT NULL, 
	synniaeg DATE NOT NULL, 
	PRIMARY KEY (id)
);
INSERT INTO treener VALUES(1,'Jurgen','Henn','1985-03-12');
INSERT INTO treener VALUES(2,'Roman','Kozhuhhovski','1983-07-09');
INSERT INTO treener VALUES(3,'Karel','Voolaid','1980-06-25');
CREATE TABLE klubi (
	id INTEGER NOT NULL, 
	nimi VARCHAR(80) NOT NULL, 
	linn VARCHAR(50) NOT NULL, 
	staadion VARCHAR(80) NOT NULL, 
	treener_id INTEGER, 
	PRIMARY KEY (id), 
	UNIQUE (nimi), 
	FOREIGN KEY(treener_id) REFERENCES treener (id)
);
INSERT INTO klubi VALUES(1,'FC Flora','Tallinn','Lillekula staadion',1);
INSERT INTO klubi VALUES(2,'Nomme Kalju','Tallinn','Hiiu staadion',2);
INSERT INTO klubi VALUES(3,'Paide Linnameeskond','Paide','Paide linnastaadion',3);
CREATE TABLE mangija (
	id INTEGER NOT NULL, 
	eesnimi VARCHAR(50) NOT NULL, 
	perekonnanimi VARCHAR(50) NOT NULL, 
	synniaeg DATE NOT NULL, 
	riik VARCHAR(50) NOT NULL, 
	palk NUMERIC(10, 2) NOT NULL, 
	klubi_id INTEGER NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(klubi_id) REFERENCES klubi (id)
);
INSERT INTO mangija VALUES(1,'Rauno','Sappinen','1996-02-23','Eesti',4200,1);
INSERT INTO mangija VALUES(2,'Markus','Poom','2000-07-07','Eesti',3900,1);
INSERT INTO mangija VALUES(3,'Marko','Lipp','1999-04-15','Eesti',3100,1);
INSERT INTO mangija VALUES(4,'Danil','Kuznetsov','2001-10-01','Eesti',2700,1);
INSERT INTO mangija VALUES(5,'Vlasi','Sinjavski','1995-09-06','Eesti',3600,2);
INSERT INTO mangija VALUES(6,'Mihkel','Ainsalu','1996-03-20','Eesti',3300,2);
INSERT INTO mangija VALUES(7,'Tomi','Saarelma','1997-11-14','Soome',2900,2);
INSERT INTO mangija VALUES(8,'Henrik','Purg','1998-01-11','Eesti',2800,3);
INSERT INTO mangija VALUES(9,'Robi','Saarma','2001-05-03','Eesti',2400,3);
INSERT INTO mangija VALUES(10,'Edgars','Berzins','1994-08-29','Lati',2500,3);
CREATE TABLE mang (
	id INTEGER NOT NULL, 
	koduklubi_id INTEGER NOT NULL, 
	voorklubi_id INTEGER NOT NULL, 
	kodu_varavad INTEGER NOT NULL, 
	voor_varavad INTEGER NOT NULL, 
	tulemus VARCHAR(10) NOT NULL, 
	algusaeg DATETIME NOT NULL, 
	publiku_arv INTEGER NOT NULL, 
	PRIMARY KEY (id), 
	FOREIGN KEY(koduklubi_id) REFERENCES klubi (id), 
	FOREIGN KEY(voorklubi_id) REFERENCES klubi (id)
);
INSERT INTO mang VALUES(1,1,2,2,1,'2:1','2026-03-14 17:00:00.000000',3120);
INSERT INTO mang VALUES(2,3,1,0,3,'0:3','2026-03-21 15:30:00.000000',1480);
CREATE VIEW turniiritabel AS
SELECT  k.nimi                                                AS klubi,
        COUNT(r.klubi_id)                                     AS mange,
        SUM(CASE WHEN r.loodud >  r.saadud THEN 1 ELSE 0 END) AS voite,
        SUM(CASE WHEN r.loodud =  r.saadud THEN 1 ELSE 0 END) AS viike,
        SUM(CASE WHEN r.loodud <  r.saadud THEN 1 ELSE 0 END) AS kaotusi,
        SUM(r.loodud)                                         AS loodud,
        SUM(r.saadud)                                         AS saadud,
        SUM(r.loodud) - SUM(r.saadud)                         AS vahe,
        SUM(CASE WHEN r.loodud >  r.saadud THEN 3
                 WHEN r.loodud =  r.saadud THEN 1
                 ELSE 0 END)                                  AS punktid
FROM    klubi k
LEFT JOIN (
        SELECT koduklubi_id AS klubi_id, kodu_varavad AS loodud,
               voor_varavad AS saadud FROM mang
        UNION ALL
        SELECT voorklubi_id AS klubi_id, voor_varavad AS loodud,
               kodu_varavad AS saadud FROM mang
) r ON r.klubi_id = k.id
GROUP BY k.id, k.nimi;
COMMIT;
