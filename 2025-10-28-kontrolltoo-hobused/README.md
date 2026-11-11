# 2025-10-28 Kontrolltöö — hobuste andmebaas (`yhobu`)

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Lugeda õpetaja fail (`Dump20251027.sql`) oma andmebaasi — nimi jääb **`yhobu`**.
Täiendada tabeleid, teha vähemalt kolm uut tabelit (treeningprogramm, treening,
personal), sisestada igasse vähemalt 10 rida (treeningprogramm: 3), muuta
omanik Üllar Lindmaa minu enda nimeks (`UPDATE`), lisada omanikuks klassikaaslane
ilma hobuseta, teha vaade `nimed` ja viis päringut vaadetena. Vastuseks: eksporditud
andmebaas ja script.

## Failid

| Fail | Mis see on |
|---|---|
| [`yhobu_Jegor_Onoprijuk.sql`](yhobu_Jegor_Onoprijuk.sql) | **eksporditud andmebaas `yhobu`** (tabelid, andmed, triggerid, vaated) |
| [`yhobu_lahendus.sql`](yhobu_lahendus.sql) | **script** — kõik minu muudatused õpetaja dumbi peale |
| [`testid.sql`](testid.sql), [`kontrollid*.sql`](kontrollid.sql) | päringute testid ja kolm meelega valesti tehtud lisamist |
| [`valjund.txt`](valjund.txt) | terve terminali logi |
| [`screenshots/`](screenshots) | logi ekraanipiltidena |
| [`build.sh`](build.sh) | kogu töö ühe käsuga uuesti jooksutamiseks |

Dumbi laadimine: `mysql -u <kasutaja> -p < yhobu_Jegor_Onoprijuk.sql`.

## Mis sai tehtud

**Uued tabelid.** `personal` (treenerid, tallimehed, muu personal),
`treeningprogramm` (nimi, kirjeldus, vastutaja → `personal`) ja `treening`
(hobune, treener, treeningukoht, programm, aeg).

**Reegel „iga tallimees töötab täpselt ühes tallis".** `personal.tall_kood` on
välisvõti `tall`-i ja `CHECK (ametikoht <> 'tallimees' OR tall_kood IS NOT NULL)`
ei lase tallimeest ilma tallita lisada. Kontroll on logis: viga 4025.

**Treeneriks ainult treener.** `treening.treener_isikukood` viitab `personal`-ile,
aga välisvõti üksi ei kontrolli ametikohta. Seepärast on trigger
`treening_treener_kontroll`: kui treeningule pannakse treeneriks tallimees, tuleb
viga *„Treeningu treener peab olema personal ametikohaga treener"*.

**Andmed.** omanik 10, hobune 34, tall 10, arst 10, inventar 12, visiit 12,
personal 12, treeningprogramm 5, treening 14. Inventar kuulub kas tallile või
omanikule (õpetaja `CHECK` nõuab täpselt üht) ja on jagatud mitme omaniku ja talli
vahel; visiitidel on seitse-kaheksa erinevat arsti. `id`, `inserted_at` ja
`updated_at` täidab MySQL ise — ma ei kirjutanud neid ühtegi korda.

**`UPDATE`, mitte kustuta + lisa.** `UPDATE omanik SET eesnimi='Jegor',
perekonnanimi='Onoprijuk' WHERE isikukood = 36576574545`. Rida jäi samaks, seega
mulle jäid ka Üllari kolm hobust (Kei, Kellendria, Kitty Hawk) ja sadul. Logis:
„Üllar Lindmaa alles: 0".

**Klassikaaslane.** Omanikuks on lisatud **Mari Tamm** ilma ühegi hobuseta
(`nimed` vaates on tema nimi tühja hobusega — `LEFT JOIN`).

## Vaated

| Vaade | Mida näitab |
|---|---|
| `nimed` | õpetaja näide: omanik + tema hobused (LEFT JOIN, ka hobuseta omanikud) |
| `tallimehed` | kõik `personal` veerud, ainult tallimehed (treenerid jäävad välja) |
| `omanike_inventari_kulu` | kui palju on iga omanik inventari eest maksnud |
| `omanike_arstimaksed` | omaniku ees- ja perekonnanimi, visiidil käinud hobune, arsti isikukood, visiidi hind |
| `hobuste_treeningud` | hobuse nimi ja mitu korda ta on treeningul käinud |
| `talli_ulevaade` | **minu oma päring:** iga talli hobuste arv, tallimeeste arv ja inventari väärtus |

## Kaks asja, mis tuleb teada

**MySQL vs MariaDB.** Minu masinas jookseb MariaDB 13, aga õpetaja dump on MySQL 8
omas (`utf8mb4_0900_ai_ci`). Dumbi laadimiseks asendasin sortimise
`utf8mb4_uca1400_ai_ci`-ga, lahenduse tegin MariaDB-s ja **eksporditud dumbis panin
sortimise tagasi `utf8mb4_0900_ai_ci`-ks**, et see laeks MySQL Workbenchisse. Eemaldasin
ka `DEFINER=` ja `YEAR(4)` / `INT(10)` laiused. Kontrollisin, et dump laeb tagasi
(logi punkt 5): 10 omanikku, 34 hobust, 6 vaadet, trigger alles.

**Klassikaaslane on näidisnimi.** Ma ei tea, keda õpetaja klassikaaslaseks pidas;
„Mari Tamm" on näidisnimi — vajadusel saab selle muuta ühe `UPDATE`-iga.
