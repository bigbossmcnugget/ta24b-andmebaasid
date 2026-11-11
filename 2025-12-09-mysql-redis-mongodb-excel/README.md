# 2025-12-09 — MySQL, Redis, MongoDB, Excel

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Oleme vaadanud SQL andmebaase (MySQL, SQLite), NoSQL andmebaase (Redis, MongoDB) ja
Exceli. Neli väikest ülesannet, **igaüks tuleb lahendada kõigi nelja andmebaasiga**
(MySQL, Redis, MongoDB, Excel) ja iga ülesande kohta kirjeldada, milline andmebaas
on selleks parim valik ja miks.

1. **Joogid** — nõia (name, level) joogid (type, productiontime, expirationtime), mäng toimib reaalajas
2. **imdbtitle.txt** — lugeda kõigisse andmebaasidesse, leida kõige pikem film
3. **Pank** — 3 klienti, igal 3 arvet (arveldusarve, säästuhoius, tähtajaline hoius), üks klient olen mina
4. **stock.zip** — lugeda üks fail andmebaasi, leida millal kurss oli kõrgeim ja madalaim

## Failid

| Ülesanne | Skript | Excel | Logi | Ekraanipilt |
|---|---|---|---|---|
| 1. Joogid | [`1_joogid.py`](1_joogid.py) | [`noiajoogid.xlsx`](noiajoogid.xlsx) | [`logid/valjund_1_joogid.txt`](logid/valjund_1_joogid.txt) | [`screenshots/1_joogid.png`](screenshots/1_joogid.png) |
| 2. IMDb | [`2_imdb.py`](2_imdb.py) | [`imdb.xlsx`](imdb.xlsx) | [`logid/valjund_2_imdb.txt`](logid/valjund_2_imdb.txt) | [`screenshots/2_imdb.png`](screenshots/2_imdb.png) |
| 3. Pank | [`3_pank.py`](3_pank.py) | [`pank.xlsx`](pank.xlsx) | [`logid/valjund_3_pank.txt`](logid/valjund_3_pank.txt) | [`screenshots/3_pank.png`](screenshots/3_pank.png) |
| 4. Aktsiad | [`4_aktsiad.py`](4_aktsiad.py) | [`aktsia_IBM.xlsx`](aktsia_IBM.xlsx) | [`logid/valjund_4_aktsiad.txt`](logid/valjund_4_aktsiad.txt) | [`screenshots/4_aktsiad.png`](screenshots/4_aktsiad.png) |

`andmed/` — ülesande faili `imdbtitle.txt` ja `IBM_daily_data.csv` (zipist `stock.zip`).

Iga skript teeb kõik neli andmebaasi ühe käivitusega ja trükib tulemused välja.
Käivitus: `python 1_joogid.py` (vaja `pymysql`, `redis`, `pymongo`, `openpyxl`;
MariaDB/MySQL, Redis ja MongoDB peavad olema käimas).

## Vastused

| Ülesanne | Vastus | Kontrollitud |
|---|---|---|
| 2. Kõige pikem film | **The Hazards of Helen (1914) — 1428 min** | MySQL, Redis, MongoDB, Excel, Python |
| 4. IBM kõrgeim sulgemiskurss | **223,43 — 26.09.2024** | MySQL, Redis, MongoDB, Excel, Python |
| 4. IBM madalaim sulgemiskurss | **9,7992 — 16.08.1993** | MySQL, Redis, MongoDB, Excel, Python |

Kõik neli andmebaasi andsid täpselt sama vastuse.

**Mis on "kurss"?** Valisin sulgemishinna (`Close`). Päeva sees on IBM-i kõrgeim
`High` 224,15 (27.09.2024) ja madalaim `Low` 9,7096 (16.08.1993) — logis on need
samuti olemas.

**Mis on "film"?** `titleType = 'movie'`. Failis on ka 341 lühifilmi (`short`), aga
need ei ole filmid. Kõige pikem **kogu** failis on samuti The Hazards of Helen,
seega vastus ei muutu.

**The Hazards of Helen on 1428 minutit**, sest see on 119-osaline seriaal
(1914–1917), mis IMDb-s on kirjas ühe "filmina". Kontrollisin, et number ei ole
viga: Python, MySQL, Redis, MongoDB ja Excel annavad kõik 1428.

## Mis iga ülesande puhul parim andmebaas on ja miks

Pikk põhjendus on iga skripti lõpus ja logis, siin kokkuvõte:

| Ülesanne | Parim | Miks |
|---|---|---|
| 1. Joogid (reaalaeg, aegumine) | **Redis** | `EXPIRE` kustutab aegunud joogi **ise** õigel hetkel. Sorted set annab "mis on praegu valmis" ühe päringuga. MongoDB TTL-indeks teeb sama, aga ainult ~1 min täpsusega; MySQL ei kustuta ise (staatus arvutatakse vaates); Excel uueneb alles avamisel. |
| 2. imdbtitle (üks tabel, maksimum) | **MySQL** | Fail on juba tabel. `ORDER BY runtimeMinutes DESC LIMIT 1` + indeks. Excelile piisab 531 reast, Redis ei sobi (iga muu päring vajab oma indeksit). |
| 3. Pank (raha, tehingud) | **MySQL** | ACID tehing + `CHECK (balance >= 0)` + välisvõtmed. Logis: 99 999 EUR katse sai `ROLLBACK`-i, jäägid jäid samaks. MongoDB mitme dokumendi tehing andis vea (vajab replica set'i), Redis ei kontrolli jääke. |
| 4. Aktsiakurss (aegrida) | **MySQL** | `date` on PRIMARY KEY, `close` indekseeritud, perioodi- ja keskmise-päringud on lihtsad. MongoDB on samuti hea (time-series); Redis annab ühe päringu kiirelt, aga 11 tuhat hash'i mälus on raiskamine. |

## Ülesanne 1 — joogid: mida ma tegin

**Valmimise ja aegumise aega ei hoia ma kusagil — see arvutatakse.** Hoian ainult
`started_at` (millal nõid alustas). `ready_at = started_at + productiontime`,
`expires_at = ready_at + expirationtime`. Nii ei pea keegi tulpasid uuendama ja mäng
saab alati reaalajas küsida, mis on valmis. MySQL-is on selleks vaade `potion`,
Excelis valemid (`=D2 + productiontime/1440`, staatus `=IF(NOW()>=…)`).

Andmetes on kaheksa jooki, sh kaks juba aegunud (`aegunud`), kolm valmis ja kolm
veel valmimisel. Mina (Jegor Onoprijuk, tase 7) olen nõidade seas.

**Redis kustutab aegunud joogid ise.** Logis on näha: 8 joogist jäi Redisesse 6 —
aegunud kaks olid `TTL <= 0`, seega ei pandud neid üldse sisse. Lisaks tegin
demo-joogi, mille TTL on 2 sekundit: enne aegumist `1`, 2 sekundi pärast `0`.

**MongoDB TTL-indeks** (`expireAfterSeconds: 0` välja `expires_at` peal) kustutab
dokumendi taustaprotsessiga umbes kord minutis, seega aegunud joogid kaovad sealt
mõne minuti jooksul pärast sisestamist. See on ülesandega kooskõlas ("pärast
säilivusaja lõppu võib jook andmebaasi alles jääda, kuid ei pea") — logis on
snapshot enne esimest kustutamist.

## Ülesanne 3 — pank: mida ma tegin

Mina olen klient: **Jegor Onoprijuk**, isikukood 50603142719, kolm arvet
(arveldusarve 2500, säästuhoius 8000, tähtajaline hoius 15000).

* **MySQL:** `customer`, `accounttype`, `account` + välisvõtmed + `CHECK (balance >= 0)`.
  Üleminek 500 EUR arveldusarvelt säästuhoiusele kui tehing; 99 999 EUR katse
  lõppes `CONSTRAINT failed` + `ROLLBACK`.
* **Redis:** kliendi ja arve hash'id + `SET` iga kliendi arvete jaoks, ülekanne `WATCH`/`MULTI`/`EXEC`.
* **MongoDB:** arved kliendi dokumendi **sees** (embedded). Mitme dokumendi tehing
  andis vea *"Transaction numbers are only allowed on a replica set member"* — see
  on logis ja on põhjus, miks pank MongoDB-s poleks esimene valik.
* **Excel:** `COUNTIF` / `SUMIF` / `VLOOKUP` valemitega kliendi arvete arv ja jääk kokku.

## Mis mul kohe ei töötanud

**Exceli valemid.** `openpyxl` kirjutab valemeid, aga ei arvuta neid — fail avanes vaateprogrammis
tühjade lahtritega. Lahendus: lasin failid läbi LibreOffice'i
(`soffice --convert-to xlsx`), mis arvutab väärtused ja salvestab nad valemite
kõrvale. Kontrollisin, et iga valemi tulemus on sama mis SQL-ist (nt IMDb: 1428;
IBM: 223,43 ja 9,7992).

**Redis ei olnud arvutis.** Kompileerisin selle lähtekoodist (Redis 8.10.2);
moodulid (RedisJSON jt) ei ehitunud, aga neid polnud vaja.
