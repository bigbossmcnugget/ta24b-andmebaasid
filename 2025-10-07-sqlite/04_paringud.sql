PRAGMA foreign_keys = ON;   -- SQLite-is tuleb see igas uues ühenduses uuesti sisse lülitada
.headers on
.mode column
-- B2 päringud
SELECT h.regkood, h.nimi AS hobune, h.synniaasta, o.nimi AS omanik, h.tallikood, t.aadress AS talli_aadress
  FROM hobune h JOIN omanik o USING (omanikukood) JOIN tall t ON t.tallikood = h.tallikood ORDER BY h.regkood;
SELECT o.nimi AS omanik, COUNT(h.regkood) AS hobuseid FROM omanik o LEFT JOIN hobune h USING (omanikukood) GROUP BY o.omanikukood;
SELECT t.tallikood, COUNT(*) AS hobuseid FROM hobune h JOIN tall t ON t.tallikood = h.tallikood GROUP BY t.tallikood;
-- võõrvõtme kontroll: olematu omanik peab andma vea
INSERT INTO hobune VALUES ('EE-0099','Test',2020,99,'T1');
