# 2026-02-19 — Triggerid ja transaktsioonid

Jegor Onoprijuk, rühm TA-24B. Andmebaas: **world** (MySQL näidisbaas, 239 riiki, 4079 linna).

| Fail | Mis see on |
|---|---|
| `triggers_transactions.sql` | kogu töö — transaktsioonide ja triggerite näited |
| `valjund.txt` | skripti päris väljund minu masinas |
| `world_koos_triggeritega.sql` | world andmebaasi dump koos minu triggerite ja logitabeliga |

```bash
mysql -u <kasutaja> -p < triggers_transactions.sql
```

Skript jookseb lõpuni ja paneb enda järelt koristades andmebaasi algseisu tagasi, seega
võib teda mitu korda järjest käivitada.

---

## Osa 1 — Transaktsioonid

Ülesande koodis oli `update ... where headofstate = 'Beatrix'`. Baasis on kolm sellist
riiki: **Aruba, Netherlands, Netherlands Antilles**.

**1.1 ROLLBACK.** Transaktsiooni sees näen ma oma muudatust (kõik kolm on
Willem-Alexander), aga pärast `ROLLBACK` on kõik tagasi `Beatrix`. See ongi mõte: kuni
`COMMIT`-i ei ole, näeb muudatust ainult minu enda ühendus.

**1.2 COMMIT.** Sama asi `COMMIT`-iga — muudatus jääb püsima.

**1.3 SAVEPOINT.** Tegin kaks muudatust, vahele `SAVEPOINT peale_hollandit`. Teine
muudatus oli teadlikult vale (`'VIGANE NIMI'`). `ROLLBACK TO SAVEPOINT` võttis tagasi
**ainult teise** muudatuse, esimene jäi alles:

```
enne rollback to savepoint   ABW  Aruba        VIGANE NIMI
parast rollback to savepoint ABW  Aruba        Beatrix
parast rollback to savepoint NLD  Netherlands  Willem-Alexander   <- jäi alles
```

**1.4 DDL teeb vaikse COMMIT-i.** See oli minu jaoks kõige kasulikum koht. Panin
transaktsiooni keskele `CREATE TABLE` — ja pärast seda ei aidanud `ROLLBACK` enam
midagi, muudatus jäi kirja:

```
parast "rollbackki"   ABW   Aruba   TEST
```

Põhjus: MySQL-is ei ole DDL transaktsiooniline. `CREATE`, `ALTER` ja `DROP` kinnitavad
poolelioleva transaktsiooni automaatselt ära (implicit commit). PostgreSQL-is see nii
ei ole — seal saab ka `CREATE TABLE` tagasi võtta.

---

## Osa 2 — Triggerid

Tegin tabeli `country_log` ja kolm triggerit:

| Trigger | Millal | Mida teeb |
|---|---|---|
| `country_before_update` | BEFORE UPDATE | kontrollib andmeid; negatiivse rahvaarvu korral `SIGNAL SQLSTATE '45000'` |
| `country_after_update` | AFTER UPDATE | kirjutab logisse, kui `headofstate` või `population` muutus |
| `city_after_insert` | AFTER INSERT | logib uue linna |

Kaks asja, mis mulle selgeks said:

**Kontroll peab olema BEFORE-trigger.** AFTER-triggeriga ei saaks vigast rida kinni
püüda — selleks hetkeks on rida juba tabelis. Test:

```
UPDATE country SET population = -5 WHERE code = 'EST';
ERROR 1644 (45000): Rahvaarv ei saa olla negatiivne
```

ja kontroll näitab, et rahvaarv jäi puutumata (1 440 200).

**Trigger on osa samast transaktsioonist.** Seda ma enne ei teadnud. Kui põhimuudatus
tagasi võtta, kaob ka triggeri kirjutatud logirida:

```
logiridu_enne                   5
logiridu_transaktsiooni_sees    6
logiridu_parast_rollbacki       5
```

See on hea — logi ei saa näidata muudatust, mida päriselt ei toimunud. Aga see tähendab
ka, et auditilogi EI SOBI sellisena turvalogiks: kui keegi proovib midagi ja rollback'ib,
ei jää jälge. Selleks oleks vaja eraldi ühendust või `CSV`/faililogi.

Logis on näha ka kasutaja, kes muudatuse tegi (`USER()`), seega on hiljem võimalik
öelda, kes mida muutis.

---

## Väike tähelepanek lõpust

Skripti lõpus panen andmed algseisu tagasi — ja ka need `UPDATE`-id käivitavad
triggerid. Seepärast on lõpus logiridu 9, mitte 5. Esimesel korral see üllatas, aga
tegelikult on see õige: tagasipanek on ka muudatus.
