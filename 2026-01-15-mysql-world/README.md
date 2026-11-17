# 2026-01-15 — MySQL + World database

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Installida WSL-i Ubuntu, Ubuntusse MySQL, seadistada kasutaja `mysql` koos õigustega,
lisada World database, avada Workbenchis World andmebaas ja vastata:
**mitmes riigis on selles andmebaasis olevate andmete põhjal riigipea Elisabeth II.**

## Vastus

**35 riiki** (`SELECT COUNT(*) FROM country WHERE HeadOfState = 'Elisabeth II'`).

Logis on ka nimekiri kontrolliks. Kontinentide kaupa (kontrollitud `GROUP BY Continent` päringuga):
Põhja-Ameerika 16, Okeaania 12, Euroopa 2, Antarktika 2, Aafrika 2, Lõuna-Ameerika 1 — kokku 35.
Siin on nii iseseisvad riigid kui ka Ühendkuningriigi, Austraalia ja Uus-Meremaa sõltuvad
territooriumid: `country` tabelis on need kõik eraldi ridadena ja riigipeaks on neil kõigil Elisabeth II.

## Failid

| Fail | Mis see on |
|---|---|
| [`valjund.txt`](valjund.txt) | terve terminali logi |
| [`screenshots/mysql_world.png`](screenshots/mysql_world.png) | logi ekraanipildina |
| [`build.sh`](build.sh) | kogu töö ühe käsuga uuesti jooksutamiseks |

## Mida ma tegin ja mille asemel

Minu arvuti on **Mac**, seega **WSL-i ja `apt` ei ole**. Tegin sama natiivselt:

| Ülesande samm | Mis ma tegin |
|---|---|
| WSL + Ubuntu + `apt install mysql-server` | MariaDB 13 (Homebrew) — MySQL-iga ühilduv server |
| kasutaja `mysql` + õigused | `CREATE USER 'mysql' ... GRANT ALL ... WITH GRANT OPTION`, sisselogimine `-u mysql -pmysql` |
| World database | õpetaja `world` dump laetud kasutajaga `mysql`: 239 riiki, 4079 linna, 984 keelt |
| Workbench | pole Windowsi; päring käsurealt (`mariadb`) — tulemus on sama |

Kontrollisin vastust ka teise päringuga (`LIKE '%Elisabeth%'`, grupeeritud) — kirjaviiside variante
pole, seega 35 on täpne.
