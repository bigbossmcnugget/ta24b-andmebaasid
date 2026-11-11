-- =====================================================================
--  2025-10-28  Kontrolltoo - hobuste andmebaas   (andmebaasi nimi: yhobu)
--  Jegor Onoprijuk, ruhm TA-24B
--
--  Lahtekoht: Dump20251027.sql (opetaja dump). Selle peal teen:
--    1) taiendan olemasolevaid tabeleid uute veergudega
--    2) loon uued tabelid: personal, treeningprogramm, treening
--    3) sisestan igasse tabelisse vahemalt 10 rida (treeningprogramm: 3+)
--    4) muudan (UPDATE) omanik Ullar Lindmaa minu enda nimeks
--    5) lisan omanikuks uhe klassikaaslase, ilma hobuseta
--    6) vaade nimed ja koik noutud paringud vaadetena
--  inserted_at / updated_at ja AUTO_INCREMENT id-d: MySQL teeb ise, neid ei kirjuta.
-- =====================================================================
USE yhobu;

-- ---------------------------------------------------------------------
-- 1) OLEMASOLEVATE TABELITE TAIENDAMINE
-- ---------------------------------------------------------------------
ALTER TABLE hobune ADD COLUMN sugu ENUM('mark','mara','ruun') NULL COMMENT 'hobuse sugu' AFTER aasta;
ALTER TABLE tall   ADD COLUMN nimi VARCHAR(64) NULL COMMENT 'talli nimi' AFTER kood;
ALTER TABLE arst   ADD COLUMN perekonnanimi VARCHAR(64) NULL AFTER eesnimi,
                   ADD COLUMN telefon VARCHAR(16) NULL;

-- ---------------------------------------------------------------------
-- 2) UUED TABELID
-- ---------------------------------------------------------------------
-- personal: treenerid, tallimehed ja muu inimressurss uhes tabelis.
-- Reegel: iga TALLIMEES tootab tapselt uhes tallis => tall_kood on tallimehel kohustuslik.
CREATE TABLE personal (
    isikukood     BIGINT UNSIGNED NOT NULL,
    eesnimi       VARCHAR(64)  NOT NULL,
    perekonnanimi VARCHAR(64)  NOT NULL,
    ametikoht     ENUM('treener','tallimees','veterinaarabi','administraator') NOT NULL,
    tall_kood     VARCHAR(6)   NULL COMMENT 'tallimehe tall (iga tallimees tootab tapselt uhes tallis)',
    telefon       VARCHAR(16)  NULL,
    palk          DECIMAL(8,2) NULL,
    inserted_at   TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at    TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    PRIMARY KEY (isikukood),
    UNIQUE KEY (telefon),
    KEY (tall_kood),
    FOREIGN KEY (tall_kood) REFERENCES tall (kood),
    CONSTRAINT personal_tallimees_chk CHECK (ametikoht <> 'tallimees' OR tall_kood IS NOT NULL)
) COMMENT='Treenerid, tallimehed ja muu personal';

CREATE TABLE treeningprogramm (
    nimi        VARCHAR(12)  NOT NULL PRIMARY KEY,
    kirjeldus   VARCHAR(255) NOT NULL,
    vastutaja   BIGINT UNSIGNED NOT NULL COMMENT 'vastutav isik',
    inserted_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at  TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (vastutaja) REFERENCES personal (isikukood)
) COMMENT='Treeningprogrammid';

CREATE TABLE treening (
    id                        INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,
    hobune_registreerimiskood VARCHAR(8)  NOT NULL,
    treener_isikukood         BIGINT UNSIGNED NOT NULL,
    tall_kood                 VARCHAR(6)  NOT NULL COMMENT 'treeninguaas (tall)',
    programm_nimi             VARCHAR(12) NOT NULL,
    treeningu_aeg             DATETIME    NOT NULL COMMENT 'kuhu / millal treening kuulub',
    inserted_at               TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at                TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    KEY (hobune_registreerimiskood), KEY (treener_isikukood), KEY (tall_kood), KEY (programm_nimi),
    FOREIGN KEY (hobune_registreerimiskood) REFERENCES hobune (registreerimiskood),
    FOREIGN KEY (treener_isikukood)         REFERENCES personal (isikukood),
    FOREIGN KEY (tall_kood)                 REFERENCES tall (kood),
    FOREIGN KEY (programm_nimi)             REFERENCES treeningprogramm (nimi)
) COMMENT='Treeningud: hobune, treener, treeningukoht, programm, aeg';

-- Treeneriks voib treeningul olla ainult personal, kelle ametikoht on 'treener'.
DELIMITER //
CREATE TRIGGER treening_treener_kontroll BEFORE INSERT ON treening
FOR EACH ROW
BEGIN
    IF (SELECT ametikoht FROM personal WHERE isikukood = NEW.treener_isikukood) <> 'treener' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Treeningu treener peab olema personal ametikohaga treener';
    END IF;
END//
DELIMITER ;

-- ---------------------------------------------------------------------
-- 3) ANDMETE SISESTAMINE (vahemalt 10 rida igasse tabelisse)
-- ---------------------------------------------------------------------
-- tall: 6 olemasolevat + 4 uut = 10
INSERT INTO tall (kood, aadress) VALUES
  ('9',  'Viljandi 1'), ('9A', 'Viljandi 2'), ('11', 'Rakvere 1'), ('11A', 'Rakvere 2');
UPDATE tall SET nimi = CONCAT('Tall ', aadress) WHERE nimi IS NULL;     -- nimed olemasolevatele

-- hobune: sugu taiendatakse olemasolevatele (34 hobust on juba olemas)
UPDATE hobune SET sugu = ELT(1 + MOD(CAST(registreerimiskood AS UNSIGNED), 3), 'mark', 'mara', 'ruun');

-- omanik: 9 olemasolevat + 1 klassikaaslane = 10 (klassikaaslane jaab ILMA hobuseta)
INSERT INTO omanik (isikukood, eesnimi, perekonnanimi, aadress, telefon) VALUES
  (50203040055, 'Mari', 'Tamm', 'Tartu', '5551234');

-- arst: 3 olemasolevat + 7 uut = 10
INSERT INTO arst (isikukood, eesnimi, perekonnanimi, telefon) VALUES
  (12312312315, 'Toomas',  'Kask',    '5600001'), (12312312316, 'Liina',   'Sepp',    '5600002'),
  (12312312317, 'Madis',   'Lill',    '5600003'), (12312312318, 'Katrin',  'Pold',    '5600004'),
  (12312312319, 'Rasmus',  'Teder',   '5600005'), (12312312320, 'Helen',   'Mägi',    '5600006'),
  (12312312321, 'Andres',  'Raud',    '5600007');

-- personal: 4 treenerit + 6 tallimeest + 2 muud = 12
INSERT INTO personal (isikukood, eesnimi, perekonnanimi, ametikoht, tall_kood, telefon, palk) VALUES
  (38001010011, 'Karl',   'Kuusk',   'treener',        NULL,  '5701001', 2400.00),
  (38502020022, 'Eve',    'Nurm',    'treener',        NULL,  '5701002', 2300.00),
  (37703030033, 'Toomas', 'Oja',     'treener',        NULL,  '5701003', 2500.00),
  (49004040044, 'Kadri',  'Mets',    'treener',        NULL,  '5701004', 2350.00),
  (36505050055, 'Peeter', 'Saar',    'tallimees',      '2',   '5701005', 1500.00),
  (38806060066, 'Rein',   'Parn',    'tallimees',      '5',   '5701006', 1450.00),
  (39107070077, 'Jaan',   'Lepik',   'tallimees',      '5A',  '5701007', 1480.00),
  (48508080088, 'Liis',   'Kask',    'tallimees',      '7',   '5701008', 1520.00),
  (38309090099, 'Marko',  'Tamm',    'tallimees',      '7A',  '5701009', 1500.00),
  (49210100010, 'Anu',    'Rebane',  'tallimees',      '7B',  '5701010', 1460.00),
  (37811110011, 'Mart',   'Ilves',   'veterinaarabi',  NULL,  '5701011', 1800.00),
  (46512120012, 'Helle',  'Sepp',    'administraator', NULL,  '5701012', 1700.00);

-- treeningprogramm: 3 reaalselt vajalikku, tegin 5
INSERT INTO treeningprogramm (nimi, kirjeldus, vastutaja) VALUES
  ('KOOLISOIT',  'Koolisoit: alused, voltigeerimine, hobuse tasakaal ja kuulekus',        38001010011),
  ('TAKISTUS',   'Takistussoit: hupped, rajasoit ja hobuse ning ratsaniku usaldus',      38502020022),
  ('VASTUPID',   'Vastupidavus: pikad maastikuringid, tempo ja hingamise treening',       37703030033),
  ('NOORHOBUNE', 'Noorhobuse opetamine: sadula ja valjade harjutamine, pealeistumine',    49004040044),
  ('TAASTUS',    'Taastusprogramm parast vigastust: kaimine, kerge sisetreening',         38001010011);

-- treening: 14 rida, erinevad hobused / treenerid / tallid / programmid
INSERT INTO treening (hobune_registreerimiskood, treener_isikukood, tall_kood, programm_nimi, treeningu_aeg) VALUES
  ('200', 38001010011, '5',  'KOOLISOIT',  '2025-10-06 17:00:00'),
  ('200', 38502020022, '5',  'TAKISTUS',   '2025-10-08 18:30:00'),
  ('201', 38001010011, '5A', 'KOOLISOIT',  '2025-10-07 16:00:00'),
  ('202', 37703030033, '7',  'VASTUPID',   '2025-10-09 15:00:00'),
  ('203', 37703030033, '7',  'VASTUPID',   '2025-10-09 16:30:00'),
  ('205', 49004040044, '7A', 'NOORHOBUNE', '2025-10-10 10:00:00'),
  ('211', 38502020022, '7B', 'TAKISTUS',   '2025-10-13 17:30:00'),
  ('211', 38001010011, '7B', 'KOOLISOIT',  '2025-10-15 17:30:00'),
  ('211', 38502020022, '7B', 'TAKISTUS',   '2025-10-20 17:30:00'),
  ('220', 37703030033, '2',  'VASTUPID',   '2025-10-14 14:00:00'),
  ('220', 49004040044, '2',  'TAASTUS',    '2025-10-21 14:00:00'),
  ('229', 38001010011, '5',  'KOOLISOIT',  '2025-10-16 18:00:00'),
  ('232', 49004040044, '5',  'NOORHOBUNE', '2025-10-17 09:30:00'),
  ('233', 38502020022, '5',  'TAKISTUS',   '2025-10-22 19:00:00');

-- inventar: kas TALLI voi OMANIKU oma (CHECK nouab uht kahest). 1 olemasolev + 11 uut = 12
INSERT INTO inventar (kirjeldus, hind, tall_kood, omanik_isikukood) VALUES
  ('Valjad',            85.00, NULL, 100000), ('Tekk',              60.50, NULL, 100001),
  ('Sadul Prestige',  1450.00, NULL, 100002), ('Kiiver',            95.00, NULL, 100003),
  ('Ratsasaapad',      180.00, NULL, 100004), ('Hobuse transpordikott', 120.00, NULL, 100006),
  ('Maneezi tokked',   240.00, '5',  NULL),   ('Soogikausid (20 tk)', 180.00, '7',  NULL),
  ('Heinaveoauto',    3200.00, '2',  NULL),   ('Kaarik',          2100.00, '7B', NULL),
  ('Treeningtool',      75.00, '5A', NULL);

-- visiit: 1 olemasolev + 11 uut = 12, ERINEVAD ARSTID
INSERT INTO visiit (hobune_registreerimiskood, arst_isikukood, visiidi_aeg, visiidi_kirjeldus, hind) VALUES
  ('200', 12312312313, '2025-10-02 10:00:00', 'Aastakontroll',                 60.00),
  ('202', 12312312314, '2025-10-03 11:30:00', 'Vaktsineerimine',               45.00),
  ('205', 12312312315, '2025-10-04 09:00:00', 'Hammaste kontroll',             70.00),
  ('211', 12312312316, '2025-10-06 14:00:00', 'Jala pehmenduskontroll',        95.50),
  ('211', 12312312317, '2025-10-10 12:00:00', 'Uuesti jalg - paranemine',      40.00),
  ('218', 12312312318, '2025-10-07 15:30:00', 'Silmapohjus',                  110.00),
  ('220', 12312312319, '2025-10-08 08:30:00', 'Pikkade jalgade krambid',      130.00),
  ('223', 12312312320, '2025-10-09 16:00:00', 'Vaktsineerimine',               45.00),
  ('229', 12312312321, '2025-10-11 10:30:00', 'Hammaste kontroll',             70.00),
  ('232', 12312312312, '2025-10-13 13:00:00', 'Aastakontroll',                 60.00),
  ('225', 12312312313, '2025-10-15 09:30:00', 'Seedehaired',                   85.00);

-- ---------------------------------------------------------------------
-- 4) UPDATE: Ullar Lindmaa -> mina (kirje jaab samaks, hobused ja inventar jaavad kaasa)
-- ---------------------------------------------------------------------
UPDATE omanik SET eesnimi = 'Jegor', perekonnanimi = 'Onoprijuk'
WHERE isikukood = 36576574545 AND eesnimi = 'Üllar' AND perekonnanimi = 'Lindmaa';

-- ---------------------------------------------------------------------
-- 5) VAADE nimed  (opetaja naide) + 6) NOUTUD PARINGUD VAATENA
-- ---------------------------------------------------------------------
CREATE OR REPLACE VIEW nimed AS
SELECT o.eesnimi, o.perekonnanimi, h.nimi
FROM omanik o LEFT JOIN hobune h ON o.isikukood = h.omanik_isikukood;

-- paring 1: koik tallimeeste andmed (treenerid jaavad valja) - koik personali tabeli veerud
CREATE OR REPLACE VIEW tallimehed AS
SELECT p.* FROM personal p WHERE p.ametikoht = 'tallimees';

-- paring 2: kui palju on iga omanik inventari eest maksnud
CREATE OR REPLACE VIEW omanike_inventari_kulu AS
SELECT o.isikukood, o.eesnimi, o.perekonnanimi,
       COUNT(i.id) AS esemeid, COALESCE(SUM(i.hind), 0) AS inventari_eest_makstud
FROM omanik o LEFT JOIN inventar i ON i.omanik_isikukood = o.isikukood
GROUP BY o.isikukood, o.eesnimi, o.perekonnanimi;

-- paring 3: omanikud seotud arstile tehtud maksetega:
--           omaniku ees- ja perekonnanimi, visiidil kainud hobuse nimi, arsti isikukood, visiidi hind
CREATE OR REPLACE VIEW omanike_arstimaksed AS
SELECT o.eesnimi, o.perekonnanimi, h.nimi AS hobune, v.arst_isikukood, v.hind
FROM visiit v
JOIN hobune h ON h.registreerimiskood = v.hobune_registreerimiskood
JOIN omanik o ON o.isikukood = h.omanik_isikukood;

-- paring 4: mitu korda iga hobune on treeningutel kaninud (hobuse nimi ja treeningute arv)
CREATE OR REPLACE VIEW hobuste_treeningud AS
SELECT h.nimi AS hobune, COUNT(t.id) AS treeninguid
FROM hobune h LEFT JOIN treening t ON t.hobune_registreerimiskood = h.registreerimiskood
GROUP BY h.registreerimiskood, h.nimi;

-- paring 5 (oma moeldud): iga talli ulevaade - hobuste arv, tallimeeste arv, inventari vaartus
CREATE OR REPLACE VIEW talli_ulevaade AS
SELECT t.kood, t.nimi,
       (SELECT COUNT(*) FROM hobune h WHERE h.tall_kood = t.kood)               AS hobuseid,
       (SELECT COUNT(*) FROM personal p WHERE p.tall_kood = t.kood)             AS tallimehi,
       (SELECT COALESCE(SUM(i.hind),0) FROM inventar i WHERE i.tall_kood = t.kood) AS inventari_vaartus
FROM tall t;
