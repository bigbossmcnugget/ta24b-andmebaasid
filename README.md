# TA-24B — Andmebaasid

Jegor Onoprijuk, rühm TA-24B, Tallinna Tehnoloogiakolledž.

Siin on minu kodutööd aine **Andmebaasid** jaoks. Iga kaust on üks ülesanne:
sees on SQL-failid, andmebaasi dump ja lühike selgitus Wordis.

| Kaust | Ülesanne | Mis sees on |
|---|---|---|
| [`2026-03-12-sqlalchemy`](2026-03-12-sqlalchemy) | SQLAlchemy, jalgpalli andmebaas | neli tabelit ORM-iga, 4 klubi turniir (12 mängu) nii SQLite-s kui MySQL-is, vaade `turniiritabel` |
| [`2026-03-19-etl`](2026-03-19-etl) | Accounts, Customers, ETL, stored procedure | account-triggerid (jäägi ajalugu vs audit), tabelid `log` ja `account_balance`, protseduurid `open_current_account` ja `transfer`, ETL `ourcustomers.csv` → vahetabel → `customer` (1000 klienti), TA24Bbank + etl dump |
| [`2026-03-26-protseduurid`](2026-03-26-protseduurid) | TA24Bbank protseduurid | vigade otsimine ja parandamine protseduurides `transfer` ja `open_current_account`, minu enda ja kahe sõbra kliendikirjed, 8 tehingut, terve andmebaasi dump |
| [`2026-04-02-pangabaas`](2026-04-02-pangabaas) | Algeline pangabaas | laenutabelid koos maksegraafikuga (annuiteet / fikseeritud põhiosa / bullet), `dates` — 2026. aasta pangapäevade kalender koos Eesti riigipühadega, `config`, protseduur pangapäeva nihutamiseks |
| [`2026-04-09-presentatsioon`](2026-04-09-presentatsioon) | Presentatsioon | DuckDB — analüütiline andmebaas. Esitlus koos minu enda mõõtmistega (2 miljonit rida, DuckDB vs SQLite) |

## Kuidas ma neid kontrollisin

Kõik SQL-failid on päriselt läbi lastud, mitte ainult kirjutatud. Panin oma sülearvutisse
MariaDB üles, laadisin sinna õpetaja dumbi ja jooksutasin oma failid peale. Iga ülesande
selgituses olevad arvud ja logiread on sealt välja kopeeritud.
