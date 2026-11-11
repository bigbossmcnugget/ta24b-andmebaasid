USE yhobu;
SELECT '=== KONTROLL 3: inventar korraga talli JA omaniku oma (CHECK peab keelama) ===' AS samm;
INSERT INTO inventar (kirjeldus, hind, tall_kood, omanik_isikukood) VALUES ('Vigane', 1.00, '2', 100000);
