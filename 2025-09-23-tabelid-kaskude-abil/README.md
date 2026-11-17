# 2025-09-23 — Tabelid käskude abil

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Luua uus kooli andmebaas SQL käskudega (tabelid inglise keeles): `Teacher`, `Subject`, `Studentgroup`,
`Student`, `Enrollment`, `Class`, `Room`, `Grade`. Igasse tabelisse vähemalt 4 rida, `Student` tabelis olen
ka mina ise. Lõpuks Workbench: Server → Data Export ja üks fail üles.

## Mida ma tegin

| Fail | Sisu |
|---|---|
| [`01_tabelid.sql`](01_tabelid.sql) | `CREATE DATABASE tunniplaan` + kõik 8 tabelit |
| [`02_andmed.sql`](02_andmed.sql) | andmed (≥ 4 rida igas tabelis) |
| [`03_kontroll.sql`](03_kontroll.sql) | kontrollpäringud ja kaks tahtlikult vigast INSERT-i |
| [`tunniplaan_dump_Jegor_Onoprijuk.sql`](tunniplaan_dump_Jegor_Onoprijuk.sql) | **eksportfail** (üks fail, struktuur + andmed) |
| [`valjund.txt`](valjund.txt), [`screenshots/`](screenshots) | logi ja ekraanipildid |

### Nõuded ja kuidas ma need täitsin

- **Class**: `id BIGINT UNSIGNED PRIMARY KEY AUTO_INCREMENT`; `subjectcode` viitab tabelile `subject`, kohustuslik;
  `studentgroupcode` viitab tabelile `studentgroup`, **ei ole** kohustuslik (NULL, tunnis 5 on ühine loeng);
  `starttime`, `endtime` `DATETIME NOT NULL`; `comments VARCHAR(255)` NULL; `CHECK (starttime < endtime)`.
- **Room**: `code VARCHAR(8)` (nt `A-309`), `seats`, `computers`.
- **Grade**: `studentidcode`, `subjectcode`, `grade` (`CHECK grade IN (1,2,3,4,5)`), `time` `DEFAULT CURRENT_TIMESTAMP`
  (vaikimisi sisestamise hetk). Kolm rida sisestasin ilma `time`-ita — aeg tuli automaatselt.
- **Student**: lisasin ka ennast (Jegor Onoprijuk). Nimi on õige, isikukood on näidis.
- **Teacher**: tegin eraldi tabeli (ülesandes oli küsimus, kas võiks olla `Staff`).

Kontroll: `INSERT` tunniga, mille lõpp on enne algust, ja hindega 6, mõlemad lükkab `CHECK` tagasi
(`ERROR 4025 ... CONSTRAINT failed`, vt logi).

Märkus: ma ei kasutanud õpetaja failide `EsimeneTund.sql` ja `2025-09-23 tunnitöö.sql` sisu — tegin skeemi ülesande tekstist.
Workbenchi asemel eksportisin `mariadb-dump`-iga; fail laeb tagasi (kontrollisin: andmebaas kustutatud ja dumbist taastatud).
