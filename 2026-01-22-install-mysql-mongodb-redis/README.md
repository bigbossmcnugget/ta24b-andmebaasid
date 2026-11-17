# 2026-01-22 — Install: wsl, mysql, mongodb, redis

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Paigaldada **MySQL** (kasutaja `mysql` koos õigustega, World database, Windowsis Workbench),
**MongoDB** (andmebaas `testandmebaas`, Windowsi klient Compass) ja **Redis**
(paigaldus, kuulatavate portide leidmine, stop / start / restart). Kõik see WSL-is (Ubuntu).

## Failid

| Fail | Mis see on |
|---|---|
| [`valjund.txt`](valjund.txt) | terve terminali logi |
| [`screenshots/install_mysql_mongodb_redis.png`](screenshots/install_mysql_mongodb_redis.png) | logi ekraanipildina |
| [`build.sh`](build.sh) | kogu töö ühe käsuga uuesti jooksutamiseks |

## Mida ma tegin ja mille asemel

Minu arvuti on **Mac (macOS, Apple silicon)**, mitte Windows, seega **WSL-i ei ole ja
`apt-get` ei ole**. Tegin sama asja natiivselt macOS-is:

| Ülesande samm | Mis ma tegin |
|---|---|
| `apt-get install mysql-server` | MariaDB 13 (Homebrew) — MySQL-iga ühilduv server, käib porti 3306 peal |
| kasutaja `mysql` + õigused | `CREATE USER 'mysql'... GRANT ALL ... WITH GRANT OPTION` ja sisselogimine `-u mysql -pmysql` |
| World database | õpetaja `world` dump laetud kasutajaga `mysql`: 239 riiki, 4079 linna, 984 keelt |
| Workbench Windowsis | pole Windowsi — ühendus ja päringud käsurealt (`mariadb`); Workbench on ainult GUI |
| MongoDB `testandmebaas` | MongoDB 8.0.17, andmebaas `testandmebaas`, kollektsioon `tudengid`: `insert`, `find`, `update` |
| Compass | pole paigaldatud (GUI-klient); sama tegin `pymongo` kaudu |
| `apt-get install redis` | Redis 8.10.2, kompileeritud lähtekoodist |
| `netstat -tunlp \| grep redis` | macOS-is `lsof -iTCP -sTCP:LISTEN -nP` — näitab mariadbd 3306, mongod 27017, redis 6379 |
| `systemctl stop / start redis` | `redis-cli shutdown nosave`, siis `redis-server` uuesti; `ping` enne ja pärast |

## Mis logist välja tuleb

* **Redis ei hoia andmeid kettal** (käivitatud `--save ""`): `set tervitus …` andis `OK`, aga pärast
  restarti on `get tervitus` tühi. See on ülesande tekstiga kooskõlas — *"Redis töötab mälus,
  andmetest saab ka kettal hoida, aga see ei ole Redise esmane eesmärk"*.
* **Kolm teenust, kolm porti**, kõik ainult `127.0.0.1` peal (võrgust ligipääsetav ei ole).
* Kasutaja `mysql` on loodud nii `localhost`-ile kui `127.0.0.1`-le; sisselogimine mõlemal
  teel töötab.

## Üks asi, mis mul kohe ei töötanud

Arvuti oli vahepeal restartitud ja kõik kolm andmebaasi olid seisma jäänud, nende andmekaustad olid
`/tmp` all ja kadunud. Seadsin andmekaustad ümber püsivasse kausta (`work/dbdata/`), lõin MariaDB
uuesti (`mariadb-install-db`) ja laadisin `world` dumbist. Seetõttu `build.sh` ei eelda varasemat
seisu — kasutaja ja World database luuakse seal alati uuesti.
