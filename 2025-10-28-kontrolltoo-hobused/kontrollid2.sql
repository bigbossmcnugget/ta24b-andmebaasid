USE yhobu;
SELECT '=== KONTROLL 2: treeningu treeneriks tallimees (trigger peab keelama) ===' AS samm;
INSERT INTO treening (hobune_registreerimiskood, treener_isikukood, tall_kood, programm_nimi, treeningu_aeg) VALUES ('200', 36505050055, '2', 'KOOLISOIT', '2025-11-01 10:00:00');
