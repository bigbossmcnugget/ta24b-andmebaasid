# 2025-09-16 — Andmete sisestamine (eksport + world päringud)

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

**A.** Workbench: Server → Data Export, valida andmebaas ja eksportida *self-contained file*, laadida fail üles.
**B.** Andmebaas `world` (3 tabelit): kes on Eesti president, mitu keelt on Venemaa kohta, mis on maailma suurim linn.

## Vastused

| Küsimus | Päring | Vastus |
|---|---|---|
| Eesti president | `SELECT Name, HeadOfState FROM country WHERE Code='EST'` | **Lennart Meri** (nii on selles andmebaasis; andmed on 2000. aastate algusest) |
| Mitu keelt Venemaa kohta | `SELECT COUNT(*) FROM countrylanguage WHERE CountryCode='RUS'` | **12** keelt (vene 86,6 % jt) |
| Suurim linn | `SELECT Name, Population FROM city ORDER BY Population DESC LIMIT 1` | **Mumbai (Bombay)** — 10 500 000 elanikku |

## Failid

| Fail | Mis see on |
|---|---|
| [`world_dump_Jegor_Onoprijuk.sql`](world_dump_Jegor_Onoprijuk.sql) | A osa: `world` eksport ühe failina (3 tabelit, CREATE + INSERT) |
| [`paringud.sql`](paringud.sql) | B osa päringud |
| [`valjund.txt`](valjund.txt) | terminali logi |
| [`screenshots/`](screenshots) | logi ekraanipildina |

Märkus: Workbenchi asemel tegin eksporti `mariadb-dump`-iga (sama tulemus: üks fail, mis sisaldab tabelite struktuuri ja andmeid).
