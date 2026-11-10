# 2026-02-26 — Triggers, procedures (TA24Bbank)

Jegor Onoprijuk, rühm TA-24B.

## Õpetaja märkus eelmisele esitusele

> *Saata tuleb dump. Siin vähe asju.*

Eelmine esitus oli ainult üks `.sql` fail. See versioon on tehtud täielikuks:
oma andmebaas, kõik triggerid, protseduurid, testandmed, testide väljund ja
**terve dump**, mille ma ise tühja baasi tagasi laadisin.

## Ülesanne

Teha `customer` tabelile triggerid `after_customer_insert`, `after_customer_update`
ja `after_customer_delete`, mis kirjutavad muudatuse tabelisse `audit`
(`tablename`, `tableid`, `operation`, `user`). Laadida üles oma koopia
TA24Bbank dumpist.

## Failid

| Fail | Mis see on |
|---|---|
| [`01_triggerid_protseduurid.sql`](01_triggerid_protseduurid.sql) | andmebaas, tabelid, **kuus triggerit**, vaade, kaks protseduuri |
| [`02_TA24Bbank_trig_dump_Jegor_Onoprijuk.sql`](02_TA24Bbank_trig_dump_Jegor_Onoprijuk.sql) | **dump** (tabelid, andmed, triggerid, vaade, protseduurid) |
| [`03_testid.sql`](03_testid.sql) | INSERT / UPDATE / DELETE testid ja audit-päringud |
| [`04_viga_test.sql`](04_viga_test.sql), [`05_pohjalikum.sql`](05_pohjalikum.sql) | ebaõnnestunud lisamine ja ROLLBACK-i kontroll |
| [`valjund.txt`](valjund.txt) | terve terminali logi |
| [`screenshots/`](screenshots) | logi ekraanipiltidena |
| [`build.sh`](build.sh) | kogu töö ühe käsuga uuesti jooksutamiseks |

## Taastamine

```
mysql -u <kasutaja> -p < 02_TA24Bbank_trig_dump_Jegor_Onoprijuk.sql
```

## Mida tegin ülesandest rohkem

**Samad triggerid ka `account` tabelile.** `after_account_insert/update/delete`
— nii on audit-tabelis näha, kes raha ja kontosid muutis, mitte ainult kliente.

**Vaade `audit_kokkuvote`** — mitu lisamist / muutmist / kustutamist on iga tabeli
kohta ja millal viimati.

**Protseduur `add_customer_with_account`** — klient ja tema esimene konto ühe
tehinguna. Kui teine `INSERT` ebaõnnestub, jääb ka klient lisamata
(`DECLARE EXIT HANDLER ... ROLLBACK`). Katsetasin meelega: sama e-posti teist
korda → viga 1062, aga ei klienti ega kontot ei tekkinud (logi punkt 3).

**Protseduur `audit_history(idcode)`** — ühe kliendi kogu ajalugu koos tema
kontodega.

## Mida audit näitab

Test lisas Anna Kase (ülesande näide), mind (Jegor Onoprijuk) koos kontoga,
neli klienti veel, muutis kaks kirjet ja kustutas ühe. Audit-tabelis on
15 rida (9 customer, 6 account), igaühel `user = jegor_onoprijuk@localhost` —
ühendus käis minu nimelise MySQL-i kasutajaga, mitte `root`-iga.

```
tabel     lisatud  muudetud  kustutatud  kokku
ACCOUNT         5         1           0      6
CUSTOMER        6         2           1      9
```

## Kaks asja, mis mul kohe ei töötanud

**`mariadb-dump --routines` jätab protseduurid vahele.** Dump tuli välja 6
triggeriga, aga protseduure polnud ühtegi — selle sain teada alles dumbi
tagasi laadides (`CALL audit_history` andis *PROCEDURE does not exist*).
Parandus: dump teha `root`-iga ja protseduurid dumbi lõppu käsitsi lisada.
Pärast seda kontrollisin uuesti: baas kustutatud → dump laetud → triggerid
töötavad (uus `INSERT` andis audit-tabelisse rea 16).

**Triggeri `DEFINER`.** Dumbist võtsin `DEFINER=...` välja, et dump laeduks ka
teise kasutaja all.
