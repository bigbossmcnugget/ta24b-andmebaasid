# 2025-10-14 — Export/import, Sakila päringud, hobuste andmebaas

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

**I** Export/import: viia `World` MySQL-ist SQLite'i. **II** Sakila andmebaasi päringud (õpetaja ülesandeid tekstis polnud,
kirjutasin ise 10 päringut). **III** Hobuste andmebaas vähemalt 8 tabeliga ja ER diagramm.

## Failid

| Fail | Mis see on |
|---|---|
| [`01_world_schema_sqlite.sql`](01_world_schema_sqlite.sql), [`02_world_kopeeri_andmed.py`](02_world_kopeeri_andmed.py) | I: World → SQLite (`world.db` tekib skripti jooksutamisel; 239 / 4079 / 984 rida) |
| [`03_sakila_paringud.sql`](03_sakila_paringud.sql) | II: 10 päringut Sakila peal |
| [`04_hobused.sql`](04_hobused.sql), [`05_hobused_paringud.sql`](05_hobused_paringud.sql) | III: 10 tabelit + andmed + päringud |
| [`hobused.db`](hobused.db) | III: valmis SQLite fail |
| [`06_er_diagramm.py`](06_er_diagramm.py), [`er_diagramm.svg`](er_diagramm.svg), [`screenshots/02_er_diagramm.png`](screenshots/02_er_diagramm.png) | III: ER diagramm (genereeritud tabelite `PRAGMA foreign_key_list` põhjal) |
| [`valjund.txt`](valjund.txt), [`screenshots/`](screenshots) | logi ja ekraanipildid |

## II — Sakila, tulemused

Filme 1000, näitlejaid 200, kliente 599, rente 16 044. Pikim film 185 min (5 filmi võrdselt). Enim filme on kategoorias
*Sports* (74). Enim filmides: **Gina Degeneres** (42). Enim renditud: **Bucket Brotherhood** (34). Enim maksnud klient:
**Karl Seal** (221,55). Tulu: pood 1 — 33 482,50; pood 2 — 33 924,06. Tagastamata rente 183; filme ilma inventarita 42.

## III — Hobuste andmebaas (10 tabelit)

`tall`, `toug`, `omanik`, `hobune`, `treener`, `treening`, `voistlus`, `tulemus`, `veterinaar`, `vaktsineerimine`.
Seosed: omanik → tall; hobune → tõug, omanik, tall; treening → hobune, treener; tulemus → võistlus, hobune
(liittabel, PK kahe veeruga); vaktsineerimine → hobune, veterinaar. Kontroll: `CHECK` (sugu, koht, kestus), võõrvõtmed
(`PRAGMA foreign_keys = ON`) — olematu hobuse tulemus annab `FOREIGN KEY constraint failed`.
Omanikuna on **Jegor Onoprijuk** (hobused Tuuli ja Pilvi).

Märkus: õpetaja näiteandmeid hobuste kohta ma ei laadinud alla; andmed on minu enda tehtud.
