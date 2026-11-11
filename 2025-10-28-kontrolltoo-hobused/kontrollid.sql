USE yhobu;
SELECT '=== KONTROLL 1: tallimees ilma tallita (CHECK peab keelama) ===' AS samm;
INSERT INTO personal (isikukood, eesnimi, perekonnanimi, ametikoht, tall_kood) VALUES (30000000001,'Test','Tallimees','tallimees',NULL);
