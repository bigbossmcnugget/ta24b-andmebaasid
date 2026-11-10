# 2026-03-05 — Python, SQLAlchemy

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Teha lihtne jalgpalli andmebaas, kus on:

* **mängijad** — eesnimi, perekonnanimi, sünniaeg, riik, klubi, palk
* **klubid** — linn, nimi, staadion, treener
* **treenerid** — eesnimi, perekonnanimi, sünniaeg
* **mängud** — koduklubi, võõrklubi, tulemus, mängu alguseaeg, publiku arv

Lisada 3 klubi, 10 mängijat, 3 treenerit, 2 mängu.
Andmebaas tuleb teha **nii SQLite-s kui ka MySQL-is**.

## Failid

| Fail | Mis see on |
|---|---|
| [`jalgpall.py`](jalgpall.py) | kogu töö — mudelid, andmed, vaade ja väljatrükk |
| [`jalgpall.sqlite`](jalgpall.sqlite) | valmis SQLite andmebaas |
| [`jalgpall_sqlite_dump.sql`](jalgpall_sqlite_dump.sql) | SQLite dump (`.dump`) |
| [`jalgpall_mysql_dump.sql`](jalgpall_mysql_dump.sql) | MySQL / MariaDB dump |
| [`valjund.txt`](valjund.txt) | terve terminali logi: venv, pip, mõlema baasi väljund, dumpide kontroll |

## Kuidas käivitada

```
mkdir python && cd python
python3 -m venv myenv
source myenv/bin/activate
pip install sqlalchemy pymysql
python3 jalgpall.py molemad
```

`molemad` asemel võib panna `sqlite` või `mysql`, kui tahad ainult ühte.

## Mida ma ise juurde mõtlesin

**Üks skript, kaks andmebaasi.** Ülesandes oli öeldud, et baas peab olema nii SQLite-s
kui MySQL-is. Ma ei kirjutanud kahte skripti — SQLAlchemy mõte ongi see, et vahetub
ainult ühendusstring:

```python
tee_andmebaas("sqlite:///jalgpall.sqlite", "SQLite")
tee_andmebaas("mysql+pymysql://root@localhost/jalgpall2026?unix_socket=/tmp/maria.sock", "MySQL / MariaDB")
```

Mõlemad baasid annavad täpselt sama turniiritabeli — see on `valjund.txt`-s näha.

**Sünniaeg, mitte vanus.** Vanus vananeb ise ära, kuupäev mitte. Seega `Date`, mitte `Integer`.

**Palk on `Numeric(10,2)`, mitte `Float`.** Raha ja ujukomaarv ei käi kokku — 0.1 + 0.2
ei ole ujukomaarvuna 0.3.

**Treener ei ole tekstiväli.** Ülesandes on klubil "treener" ja eraldi on treenerite
tabel. Panin klubile `treener_id` viite — muidu oleks sama inimese nimi kahes kohas.

**Mängu tulemus on kahel kujul.** `kodu_varavad` ja `voor_varavad` on arvutamiseks
(nendest tuleb turniiritabel), `tulemus` on string `"2:1"` inimesele lugemiseks.

**Turniiritabel on vaade, mitte tabel.** Punkte ei hoia kuskil — need arvutatakse
mängudest. Vaade `turniiritabel` teeb igast mängust kaks rida (kodu ja võõrsil)
`UNION ALL`-iga ja grupeerib klubi järgi. Nii ei saa punktiseis andmetest lahku minna.
`CREATE VIEW` on puhta SQL-ina, sest vaade ei ole ORM-i osa.

**PyMySQL, mitte mysqlclient.** `mysqlclient` tahab C-kompilaatorit ja MySQL-i
arendusfaile. PyMySQL on puhas Python — `pip install pymysql` ja valmis.

## Kontroll

Mõlemad dumbid laadisin puhtasse andmebaasi tagasi (`jalgpall_test` ja uus
`uus.sqlite`) ja vaade `turniiritabel` andis seal sama tulemuse. Logi on `valjund.txt` lõpus.

Lõppseis mõlemas baasis:

```
#  klubi                   M  V  Vi  K   L   S  +/-   P
1  FC Flora                2  2   0  0   5   1   +4   6
2  Nomme Kalju             1  0   0  1   1   2   -1   0
3  Paide Linnameeskond     1  0   0  1   0   3   -3   0
```
