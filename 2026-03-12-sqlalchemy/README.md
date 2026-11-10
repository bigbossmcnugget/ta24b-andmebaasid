# 2026-03-12 — SQLAlchemy, jalgpalli andmebaas ja turniir

Jegor Onoprijuk, rühm TA-24B

## Mis siin on

| Fail | Mis see on |
|---|---|
| `jalgpall.py` | kogu töö: SQLAlchemy mudelid, andmed, turniiri genereerimine ja vaade |
| `jalgpall.sqlite` | valmis SQLite andmebaas |
| `jalgpall_sqlite_dump.sql` | SQLite dump |
| `jalgpall_mysql_dump.sql` | MySQL / MariaDB dump (koos vaatega) |
| `turniiritabel_vaade.sql` | vaate SQL eraldi, et oleks lihtsam lugeda |
| `valjund.txt` | skripti päris väljund mõlema andmebaasiga |

## Käivitamine

```bash
python3 -m venv myenv
source myenv/bin/activate
pip install sqlalchemy pymysql

python3 jalgpall.py sqlite     # ainult SQLite
python3 jalgpall.py mysql      # ainult MySQL
python3 jalgpall.py molemad    # mõlemad järjest
```

Ülesandes oli `pip install mysqlclient`. Mina kasutasin **PyMySQL**-i, sest see on
puhas Python ja seda ei pea kompileerima — `mysqlclient` nõuab `build-essential`-i ja
`libmysqlclient-dev`-i. SQLAlchemy jaoks muutub ainult üks sõna ühendusstringis
(`mysql+pymysql://` asemel `mysql+mysqldb://`), kogu ülejäänud kood jääb samaks.

## Andmemudel

Neli tabelit, nii nagu ülesandes:

- **klubi** — nimi, linn, staadion, treener (FK)
- **treener** — eesnimi, perekonnanimi, sünniaeg
- **mangija** — eesnimi, perekonnanimi, sünniaeg, riik, palk, klubi (FK)
- **mang** — koduklubi (FK), võõrklubi (FK), tulemus, algusaeg, publiku arv

Paar valikut, mis olid teadlikud:

- Sünniaeg on **kuupäev**, mitte vanus — vanus muutub iga aasta, sünnikuupäev mitte.
- Palk on `Numeric(10,2)`, mitte `Float` — ujukomaarvuga tekiks sentide ümardamisviga.
- Mängu tulemus on andmebaasis **kaks arvu** (`kodu_varavad`, `voor_varavad`) ja lisaks
  tekstiväli `tulemus` kujul `"2:1"`. Ainult tekstist ei saaks punkte arvutada.

## Turniir

Nelja klubi vahel on iga paar kaks korda — üks kord kodus, teine kord võõrsil:
**4 × 3 = 12 mängu**. Skript genereerib need ise, kahekordse tsükliga üle klubide,
jättes vahele kombinatsiooni, kus klubi mängiks iseendaga.

## Vaade `turniiritabel`

Vaadet ei saa ORM-iga teha, seega on ta puhas SQL. Trikk on selles, et iga mäng annab
tabelisse **kaks rida** — ühe koduklubi ja ühe võõrklubi vaatest — ja alles siis saab
grupeerida:

```sql
SELECT koduklubi_id AS klubi_id, kodu_varavad AS loodud, voor_varavad AS saadud FROM mang
UNION ALL
SELECT voorklubi_id AS klubi_id, voor_varavad AS loodud, kodu_varavad AS saadud FROM mang
```

Punktid: võit 3, viik 1, kaotus 0. `LEFT JOIN` klubi pealt tagab, et ka mängimata
klubi oleks tabelis olemas (0 punktiga), mitte ei kaoks ära.

## Tulemus

Sama skript, kaks andmebaasi, täpselt sama väljund:

```
#  klubi                   M  V  Vi  K   L   S  +/-   P
-------------------------------------------------------
1  FC Flora                6  4   1  1  11   5   +6  13
2  Paide Linnameeskond     6  3   2  1   8   5   +3  11
3  Narva Trans             6  3   0  3   6   5   +1   9
4  Levadia                 6  0   1  5   3  13  -10   1
```

Kontroll: 4 klubi × 6 mängu = 24 kirjet, aga mänge on 12 — iga mäng on kahe klubi
tabelis. Löödud väravaid kokku 28 ja saadud väravaid kokku 28, ehk arvud klapivad.
