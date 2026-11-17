# 2025-09-09 — drawSQL eksport

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Teamsis oli ülesande tekstiks ainult „Fail lisatud" ja viitefail `drawSQL-mysql-export-2025-09-09.sql`
(õpilaste, rühmade, õppeainete ja esindajate skeem, tehtud drawSQL-iga). Täpsemat juhist polnud,
seega tegin selle, mis failiga loogiline on: lugesin selle MySQL-i/MariaDB-sse, parandasin vead, lisasin andmed ja päringud, eksportisin.

## Failid

| Fail | Mis see on |
|---|---|
| [`01_drawSQL-mysql-export-2025-09-09_originaal.sql`](01_drawSQL-mysql-export-2025-09-09_originaal.sql) | õpetaja fail muutmata |
| [`02_parandatud_skeem.sql`](02_parandatud_skeem.sql) | minu parandatud skeem |
| [`03_andmed_ja_paringud.sql`](03_andmed_ja_paringud.sql) | andmed (sh mina, Jegor Onoprijuk) ja 3 päringut |
| [`drawsql0909_dump_Jegor_Onoprijuk.sql`](drawsql0909_dump_Jegor_Onoprijuk.sql) | valmis andmebaasi eksport |
| [`valjund.txt`](valjund.txt), [`screenshots/`](screenshots) | logi ja ekraanipilt |

## Mis originaalfailis ei töötanud

- `Esindaja` ja `Rühmaine` tabelitele on kaks korda `ADD PRIMARY KEY` — see annab
  `ERROR 1068 (42000): Multiple primary key defined` (vt logi). Tabelil saab olla ainult üks primaarvõti, seega tegin liitvõtmed:
  `Esindaja (õpilaseidkood, kood)` ja `Rühmaine (rühm, aine)` (seosetabel rühma ja aine vahel on õige koht liitvõtmele).
- Veerunimi `peekonnanimi` → `perekonnanimi` (trükiviga).
- Tabelid tuli luua õiges järjekorras (esmalt `Rühm`, `Õppeaine`, siis need, mis neile viitavad).

## Tulemus

5 tabelit, andmed igas, võõrvõtmed töötavad. Päringud: õpilasi rühmades (TA-24B: 2), õpilane ja tema esindaja,
rühmade õppeained (TA-24B: Andmebaasid, Operatsioonisüsteemid, Programmeerimise alused).
