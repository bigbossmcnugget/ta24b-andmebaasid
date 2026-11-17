-- 2025-09-16 Andmete sisestamine, B osa (andmebaas world)  -  Jegor Onoprijuk, TA-24B
-- Kes on Eesti president?
SELECT Name, HeadOfState FROM country WHERE Code = 'EST';
-- Mitu keelt on andmebaasis Venemaa kohta?
SELECT COUNT(*) AS keeli FROM countrylanguage WHERE CountryCode = 'RUS';
-- Maailma suurim linn (rahvaarvu järgi)
SELECT Name, CountryCode, Population FROM city ORDER BY Population DESC LIMIT 1;
