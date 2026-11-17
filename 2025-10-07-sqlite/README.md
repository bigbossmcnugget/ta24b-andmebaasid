# 2025-10-07 — SQLite

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

**A** — lugeda SQLite kohta (manusandmebaas, üks fail, 5 andmetüüpi, piiratud `ALTER TABLE`, `.mode csv` / `.import`).
**B1** — kopeerida MySQL andmebaas `World` SQLite'i (struktuur + andmed).
**B2** — teha SQLite andmebaas hobuste, omanike ja tallide kohta; lisada ka ennast omanikuna ja vähemalt üks hobune.

## Failid

| Fail | Mis see on |
|---|---|
| [`01_world_schema_sqlite.sql`](01_world_schema_sqlite.sql) | B1: `world` struktuur SQLite'i jaoks |
| [`02_world_kopeeri_andmed.py`](02_world_kopeeri_andmed.py) | B1: kopeerib andmed MySQL-ist faili `world.db` |
| [`world.db`](world.db) | B1 tulemus — 239 riiki, 4079 linna, 984 keelerida |
| [`03_hobused.sql`](03_hobused.sql) | B2: tabelid `tall`, `omanik`, `hobune` + andmed |
| [`04_paringud.sql`](04_paringud.sql) | B2: päringud + võõrvõtme kontroll |
| [`hobused.db`](hobused.db) | B2 tulemus |
| [`valjund.txt`](valjund.txt), [`screenshots/`](screenshots) | logi ja ekraanipilt |

## B1 — mida SQLite's teisiti on

- `ENUM` pole olemas → `TEXT` + `CHECK (... IN (...))` (`Continent`, `IsOfficial`).
- `DECIMAL`/`CHAR(n)` → `REAL` / `TEXT` (SQLite tüübid on 5: NULL, INTEGER, REAL, TEXT, BLOB).
- `AUTO_INCREMENT` → `INTEGER PRIMARY KEY AUTOINCREMENT`.
- Kontroll peale kopeerimist: 239 / 4079 / 984 rida (sama, mis MySQL-is); Eesti `HeadOfState` = Lennart Meri; `Elisabeth II` = 35 riiki.

## B2 — hobuste andmemudel

- `tall(tallikood, aadress)`
- `omanik(omanikukood, nimi, aadress, telefon, tallikood → tall)` — omanikul on tall, tallis võib olla palju omanikke
- `hobune(regkood, nimi, synniaasta, omanikukood → omanik, tallikood → tall)` — igal hobusel üks omanik (omanikul mitu hobust), hobune on täpselt ühes tallis

Omanikuna on tabelis **Jegor Onoprijuk** ja tal on kaks hobust (Tuuli, Pilvi).
**Märkus:** õpetaja CSV-faile (`hobune.csv`, `omanik.csv`, `tall.csv`) ma ei laadinud alla, seega andmed on minu enda tehtud, struktuur on ülesande järgi.

**Üks asi, mis mul alguses valesti läks:** SQLite'is on võõrvõtmete kontroll vaikimisi välja lülitatud ja `PRAGMA foreign_keys = ON` kehtib ainult ühe ühenduse jooksul. Esimesel katsel jooksid päringud eraldi ühenduses ja olematu omanikuga hobuse `INSERT` läks läbi. Lisasin PRAGMA ka `04_paringud.sql` algusesse — nüüd annab `FOREIGN KEY constraint failed`.
