PRAGMA foreign_keys = ON;
.headers on
.mode column
-- hobused omanike, tõu ja talliga
SELECT h.regkood, h.nimi, h.synniaasta, t.nimi AS toug, o.nimi AS omanik, ta.nimi AS tall
  FROM hobune h JOIN toug t USING (tougkood) JOIN omanik o USING (omanikukood) JOIN tall ta ON ta.tallikood = h.tallikood ORDER BY h.regkood;
-- võistluste tulemused
SELECT v.nimi AS voistlus, tu.koht, h.nimi AS hobune, tu.aeg_sek FROM tulemus tu JOIN voistlus v ON v.id = tu.voistlus_id JOIN hobune h USING (regkood) ORDER BY v.id, tu.koht;
-- treeningute arv ja kogukestus hobuse kohta
SELECT h.nimi, COUNT(*) AS treeninguid, SUM(kestus_min) AS minuteid FROM treening t JOIN hobune h USING (regkood) GROUP BY h.regkood ORDER BY minuteid DESC;
-- minu hobuste vaktsineerimised
SELECT h.nimi, va.vaktsiin, va.kuupaev, ve.nimi AS veterinaar FROM vaktsineerimine va JOIN hobune h USING (regkood) JOIN veterinaar ve USING (vetkood) JOIN omanik o USING (omanikukood) WHERE o.nimi = 'Jegor Onoprijuk' ORDER BY va.kuupaev;
-- võõrvõtme kontroll: viga peab tulema
INSERT INTO tulemus VALUES (1,'EE-9999',1,1.0);
