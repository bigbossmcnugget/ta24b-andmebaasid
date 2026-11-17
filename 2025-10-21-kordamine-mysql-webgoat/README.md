# 2025-10-21 — Kordamine: Virtualbox, Lubuntu, mysql, WebGoat

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

Paigaldada VirtualBox ja Lubuntu, Lubuntusse MySQL (`apt update`, `upgrade`, `install mysql-server`),
kontrollida (`service mysql status`, konf `/etc/mysql`), teha kasutaja
`create user mysql identified by 'mysql'; grant all on *.* to mysql;`, seadistada MySQL nii, et
hostmasinast pääseb ligi NAT / port forwardinguga (hostiport **3310** → masin 3306), paigaldada docker
ja käivitada **OWASP WebGoat** (`docker run --name webgoat -it -p 127.0.0.1:8080:8080 -p 127.0.0.1:9090:9090 webgoat/webgoat`),
registreerida end ja uurida SQL injectionit. Lisafail `script.sql` — päringud `world` andmebaasil.

## Failid

| Fail | Mis see on |
|---|---|
| [`valjund.txt`](valjund.txt) | terve logi (MySQL osa + WebGoat) |
| [`screenshots/1_mysql_ubuntu.png`](screenshots/1_mysql_ubuntu.png) | MySQL osa ekraanipildina |
| [`screenshots/2_webgoat_sql_injection.png`](screenshots/2_webgoat_sql_injection.png) | WebGoat osa ekraanipildina |
| [`script.sql`](script.sql) | õpetaja fail — päringud `world` andmebaasil, jooksutatud |
| [`build_mysql.sh`](build_mysql.sh), [`assemble.sh`](assemble.sh) | kogu MySQL osa ja logi kokkupanek |
| [`tcp_forward.py`](tcp_forward.py) | port forwarding host:3310 → masin:3306 |
| [`webgoat_sql.py`](webgoat_sql.py) | WebGoat: registreerimine ja SQL injection ülesannete lahendamine |

## Mida ma tegin ja mille asemel

Minu arvuti on Mac (Apple silicon). Lubuntu ISO + VirtualBox käsitsi paigaldades oleks läinud tunde, seega:

| Ülesande samm | Mis ma tegin |
|---|---|
| VirtualBox + Lubuntu | **OrbStack Ubuntu 24.04 virtuaalmasin** `ta24b-lubuntu` (oma Linuxi tuum, `systemd`, oma IP 192.168.139.206) |
| `apt update` / `upgrade` / `install mysql-server` | täpselt need käsud masinas; paigaldus **MySQL 8.0.46** (päris Oracle MySQL, mitte MariaDB) |
| `service mysql status`, `/etc/mysql` | logis: `active (running)`, kaust `/etc/mysql` olemas |
| kasutaja `mysql` | `CREATE USER 'mysql'@'%' ... GRANT ALL ON *.* ...` |
| port forwarding 3310 | `bind-address = 0.0.0.0` masinas, hostis [`tcp_forward.py`](tcp_forward.py): `127.0.0.1:3310` → masina `3306` |
| docker + WebGoat | `webgoat/webgoat` (arm64) kontenier käib **hosti dockeris (OrbStack)**, mitte masina sees; pordid 8080 ja 9090 täpselt nagu ülesandes |

## Tulemus

**MySQL:** hostist, pordi 3310 kaudu, sisse logides on `@@version = 8.0.46-0ubuntu0.24.04.5`,
`@@hostname = ta24b-lubuntu` — see on tõestus, et ühendus läheb tõesti masinas olevasse MySQL-i.
`world`: 239 riiki, 4079 linna, 984 keelt.

**`script.sql`** jooksutatud pordi 3310 kaudu: Eesti riigipea on nüüd *Alar Karis*, tekkis riik
*Aliens colony* (`ALI`) linnaga *Colony* ja kontinentide kokkuvõte (Aasias 51 riiki, 3,7 miljardit inimest).

**WebGoat:** registreeritud kasutaja `jegoronoprijuk`; lahendatud **kõik 9 ülesannet** lessonist
*SQL Injection (intro)* ja WebGoat ise kinnitab seda (`lessonoverview`: 9 / 9):

| Ülesanne | Mis tehti |
|---|---|
| 2, 3, 4, 5 | `SELECT`, `UPDATE`, `ALTER TABLE`, `GRANT ALL ON grant_rights TO unauthorized_user` |
| 5a | `Smith'` + `OR` + `'1' = '1` — tingimus muutub alati tõeseks, tuleb terve tabel |
| 5b | `userid = 1 or 1=1` — numbriline süstimine, jutumärke pole vaja |
| 8 | `3SL99A' or '1'='1` — stringi süstimine, näeb kõigi töötajate andmeid |
| 9 | `3SL99A'; update employees set salary=90000 where last_name='Smith'; --` — teine käsk `;` järel |
| 10 | `a'; drop table access_log; --` — logitabel kustutatud |

Ülesannete 5 ja 5a vastused ei tulnud esimesel katsel: 5-s tuli WebGoat'i lessoni tekstist välja, et tabel
on `grant_rights` ja kasutaja `unauthorized_user` (mitte `UnauthorizedUser`), 5a-s vajas tingimus ülakoma
`Smith'` lõpus ja tühikutega `'1' = '1`.

## Mida teada

* **WebGoat on kasutajale 127.0.0.1 peal** ja see on õppeprogramm, mis on meelega haavatav — kasutus ainult kohalikus
  konteineris, mitte avalikku võrku.
* **Konteineri staatus `unhealthy` logis on kirjas aus.** Pildi enda tervisekontroll käivitab `curl`-i, mida pildis ei
  ole (`curl: not found`), seega on see alati `unhealthy`. WebGoat ise töötab: `HTTP 200`, sisselogimine ja õppetunnid
  töötavad.
* **WebGoat paroolipiirang:** 6–10 märki, seega on parool lühike; kasutaja on ainult selles ühes lokaalses konteineris.
* **Mitte tehtud:** VirtualBoxi ja Lubuntut ma ei paigaldanud — asendasin OrbStack Ubuntu masinaga (põhjus ülal).
