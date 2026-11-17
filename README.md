# TA-24B — Andmebaasid

Jegor Onoprijuk, rühm TA-24B, Tallinna Tehnoloogiakolledž.

Siin on minu kodutööd aine **Andmebaasid** jaoks. Iga kaust on üks ülesanne:
sees on SQL-failid, andmebaasi dump ja lühike selgitus Wordis.

| Kaust | Ülesanne | Mis sees on |
|---|---|---|
| [`2025-12-09-mysql-redis-mongodb-excel`](2025-12-09-mysql-redis-mongodb-excel) | MySQL, Redis, MongoDB, Excel | neli ülesannet (joogid, IMDb, pank, aktsiad), igaüks neljas andmebaasis; vastused kontrollitud kõigis; iga ülesande kohta põhjendus, milline andmebaas sobib |
| [`2025-11-25-mongodb-hobused`](2025-11-25-mongodb-hobused) | MongoDB — hobuste andmebaas | viis kollektsiooni (omanikud, tallid, hobused, varustus, treeningud), olen ise omanike seas, `find` mis tagastab mulle kuuluva varustuse |
| [`2025-09-16-andmete-sisestamine`](2025-09-16-andmete-sisestamine) | Andmete sisestamine | `world` andmebaasi eksport ühe failina + päringud: Eesti president, Venemaa keeled (12), maailma suurim linn (Mumbai) |
| [`2025-09-23-tabelid-kaskude-abil`](2025-09-23-tabelid-kaskude-abil) | Tabelid käskude abil | kooli andmebaas `tunniplaan`: 8 tabelit (teacher, subject, studentgroup, student, enrollment, class, room, grade), CHECK piirangud, andmed, eksporditud dump |
| [`2025-10-21-kordamine-mysql-webgoat`](2025-10-21-kordamine-mysql-webgoat) | Kordamine: Virtualbox, Lubuntu, mysql, WebGoat | Ubuntu-masin (OrbStack) päris MySQL 8.0.46-ga, kasutaja `mysql`, port forwarding 3310, `script.sql` world peal, WebGoat konteiner ja kõik 9 SQL injection ülesannet lahendatud |
| [`2025-10-28-kontrolltoo-hobused`](2025-10-28-kontrolltoo-hobused) | Kontrolltöö — hobuste andmebaas (`yhobu`) | õpetaja dump + minu täiendused: uued tabelid `personal`, `treeningprogramm`, `treening`, CHECK ja trigger, 6 vaadet, eksporditud dump |
| [`2025-11-04-prisma-algus`](2025-11-04-prisma-algus) | Prisma (PRISMA.docx) | dokumendi näite järgi tehtud projekt: User + Article + enum Positions, migratsioon, `script.ts` CRUD-i ja `@unique` kontrolliga |
| [`2025-11-11-prisma-world-user`](2025-11-11-prisma-world-user) | Prisma: World + User/Post | oma nimeline MySQL-i kasutaja, `db pull` world-baasist, juurde lisatud `university` tabel riikide küljes, teises osas uus baas `jegor_blog` migratsiooniga |
| [`2025-11-18-jalgpall-prisma`](2025-11-18-jalgpall-prisma) | Jalgpall — Prisma + MySQL | Prisma skeem (Player, Club, Coach, Game, Country + vahetabel), n:m treener↔klubi kus olen ise kahe klubi peatreener, `createdat` vaikeväärtusega CURRENT_TIMESTAMP |
| [`2026-01-15-mysql-world`](2026-01-15-mysql-world) | MySQL + World database | kasutaja `mysql`, World database, päring „mitmes riigis on riigipea Elisabeth II" → **35**; WSL-i asemel natiivne macOS |
| [`2026-01-22-install-mysql-mongodb-redis`](2026-01-22-install-mysql-mongodb-redis) | Install: mysql, mongodb, redis | kasutaja `mysql` + World database, MongoDB `testandmebaas`, Redis portide leidmine ja stop/start; WSL-i asemel natiivne macOS, kõik logis ja ekraanipildil |
| [`2026-01-29-paringud-drizzle`](2026-01-29-paringud-drizzle) | Päringud (world) + Drizzle | kaheksa päringut `world` baasil (sh kaalutud keskmine eluiga), Drizzle + MySQL: tabel `test`, `generate`, `push`, CRUD |
| [`2026-02-05-tookeskkond-mysql-3307-sakila`](2026-02-05-tookeskkond-mysql-3307-sakila) | Kontrollige oma töökeskkonda | MySQL (MariaDB) eraldi serverina pordil 3307, kasutaja `mysql` kõigi õigustega, Sakila andmebaas (1000 filmi, 599 klienti), kontrollpäringud |
| [`2026-02-19-triggerid-transaktsioonid`](2026-02-19-triggerid-transaktsioonid) | Triggerid ja transaktsioonid | world-baasil: COMMIT/ROLLBACK, SAVEPOINT, DDL implicit commit, kolm triggerit koos logitabeliga |
| [`2026-02-26-triggerid-protseduurid`](2026-02-26-triggerid-protseduurid) | Triggers, procedures (TA24Bbank) | triggerid `customer` ja `account` tabelitele → `audit`, vaade, protseduurid, testid, ekraanipildid ja **terve dump** (õpetaja palvel) |
| [`2026-03-05-python-sqlalchemy`](2026-03-05-python-sqlalchemy) | Python, SQLAlchemy — jalgpalli andmebaas | 3 klubi, 3 treenerit, 10 mängijat, 2 mängu; üks skript teeb baasi nii SQLite-s kui MySQL-is, vaade `turniiritabel`, terve terminali logi venv-ist dumpide kontrollini |
| [`2026-03-12-sqlalchemy`](2026-03-12-sqlalchemy) | SQLAlchemy, jalgpalli andmebaas | neli tabelit ORM-iga, 4 klubi turniir (12 mängu) nii SQLite-s kui MySQL-is, vaade `turniiritabel` |
| [`2026-03-19-etl`](2026-03-19-etl) | Accounts, Customers, ETL, stored procedure | account-triggerid (jäägi ajalugu vs audit), tabelid `log` ja `account_balance`, protseduurid `open_current_account` ja `transfer`, ETL `ourcustomers.csv` → vahetabel → `customer` (1000 klienti), TA24Bbank + etl dump |
| [`2026-03-26-protseduurid`](2026-03-26-protseduurid) | TA24Bbank protseduurid | vigade otsimine ja parandamine protseduurides `transfer` ja `open_current_account`, minu enda ja kahe sõbra kliendikirjed, 8 tehingut, terve andmebaasi dump |
| [`2026-04-02-pangabaas`](2026-04-02-pangabaas) | Algeline pangabaas | laenutabelid koos maksegraafikuga (annuiteet / fikseeritud põhiosa / bullet), `dates` — 2026. aasta pangapäevade kalender koos Eesti riigipühadega, `config`, protseduur pangapäeva nihutamiseks |
| [`2026-04-09-presentatsioon`](2026-04-09-presentatsioon) | Presentatsioon | DuckDB — analüütiline andmebaas. Esitlus koos minu enda mõõtmistega (2 miljonit rida, DuckDB vs SQLite) |

## Kuidas ma neid kontrollisin

Kõik SQL-failid on päriselt läbi lastud, mitte ainult kirjutatud. Panin oma sülearvutisse
MariaDB üles, laadisin sinna õpetaja dumbi ja jooksutasin oma failid peale. Iga ülesande
selgituses olevad arvud ja logiread on sealt välja kopeeritud.
