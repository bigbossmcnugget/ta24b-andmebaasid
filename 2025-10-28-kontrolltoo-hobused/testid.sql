USE yhobu;
SELECT CURRENT_USER() AS uhendus, DATABASE() AS andmebaas;
SELECT '=== ridu igas tabelis (nouue: vahemalt 10, treeningprogramm 3+) ===' AS samm;
SELECT 'omanik' AS tabel, COUNT(*) AS ridu FROM omanik UNION ALL SELECT 'hobune', COUNT(*) FROM hobune
 UNION ALL SELECT 'tall', COUNT(*) FROM tall UNION ALL SELECT 'arst', COUNT(*) FROM arst
 UNION ALL SELECT 'inventar', COUNT(*) FROM inventar UNION ALL SELECT 'visiit', COUNT(*) FROM visiit
 UNION ALL SELECT 'personal (uus)', COUNT(*) FROM personal UNION ALL SELECT 'treeningprogramm (uus)', COUNT(*) FROM treeningprogramm
 UNION ALL SELECT 'treening (uus)', COUNT(*) FROM treening;
SELECT '=== UPDATE: Ullar Lindmaa -> Jegor Onoprijuk (sama isikukood, hobused jaid kaasa) ===' AS samm;
SELECT o.isikukood, o.eesnimi, o.perekonnanimi, COUNT(h.registreerimiskood) AS hobuseid FROM omanik o
 LEFT JOIN hobune h ON h.omanik_isikukood = o.isikukood WHERE o.isikukood = 36576574545 GROUP BY o.isikukood;
SELECT COUNT(*) AS ullar_lindmaa_alles FROM omanik WHERE eesnimi='Üllar' AND perekonnanimi='Lindmaa';
SELECT '=== klassikaaslane (omanik ilma hobuseta) ===' AS samm;
SELECT o.eesnimi, o.perekonnanimi, COUNT(h.registreerimiskood) AS hobuseid FROM omanik o
 LEFT JOIN hobune h ON h.omanik_isikukood=o.isikukood WHERE o.isikukood=50203040055 GROUP BY o.isikukood;
SELECT '=== VAADE nimed (osa, omanikud ilma hobuseta ka) ===' AS samm;
SELECT * FROM nimed WHERE nimi IS NULL OR perekonnanimi IN ('Onoprijuk','Tamm') ORDER BY perekonnanimi, nimi LIMIT 12;
SELECT '=== PARING 1: vaade tallimehed (koik personali veerud, treenerid valjas) ===' AS samm;
SELECT * FROM tallimehed;
SELECT '=== PARING 2: vaade omanike_inventari_kulu ===' AS samm;
SELECT * FROM omanike_inventari_kulu ORDER BY inventari_eest_makstud DESC;
SELECT '=== PARING 3: vaade omanike_arstimaksed ===' AS samm;
SELECT * FROM omanike_arstimaksed ORDER BY hind DESC;
SELECT '=== PARING 4: vaade hobuste_treeningud (ainult hobused, kes kaisid) ===' AS samm;
SELECT * FROM hobuste_treeningud WHERE treeninguid > 0 ORDER BY treeninguid DESC, hobune;
SELECT '=== PARING 5 (oma): vaade talli_ulevaade ===' AS samm;
SELECT * FROM talli_ulevaade ORDER BY kood;
SELECT '=== audit-veerud: inserted_at / updated_at taidab MySQL ise ===' AS samm;
SELECT id, kirjeldus, hind, inserted_at, updated_at FROM inventar ORDER BY id LIMIT 4;
