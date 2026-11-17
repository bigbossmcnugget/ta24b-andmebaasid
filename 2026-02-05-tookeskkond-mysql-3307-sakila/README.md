# 2026-02-05 — Kontrollige oma töökeskkonda

Jegor Onoprijuk, rühm TA-24B.

## Ülesanne

WSL-is (Ubuntu) kontrollida, et MySQL töötab (`systemctl status mysql`) ja kasutab **porti 3307**
(`netstat -tlpn | grep mysql`; vajadusel `/etc/mysql/mysql.conf.d`: `port 3307`, `bind-address 0.0.0.0`),
Windowsis kontrollida, et seal ei tööta teine MySQL, mis porte segaks; laadida alla
**Sakila** andmebaas (`curl`/`wget`) ja lugeda see sisse (`schema` fail, siis andmed);
Workbenchi jaoks peab olema kasutaja `mysql`, kellele on antud kõik õigused.

## Failid

| Fail | Mis see on |
|---|---|
| [`valjund.txt`](valjund.txt) | terve terminali logi |
| [`screenshots/mysql3307_sakila.png`](screenshots/mysql3307_sakila.png) | logi ekraanipildina |
| [`my3307.cnf`](my3307.cnf) | serveri seadistus (port 3307) |
| [`build.sh`](build.sh) | kogu kontroll ühe käsuga uuesti jooksutamiseks |

## Mis tehtud

| Ülesande samm | Mis ma tegin |
|---|---|
| MySQL töötab? | MariaDB 13 eraldi server (`pid` logis), käivitatud seadistusfailiga `my3307.cnf` |
| Port 3307 | `lsof -iTCP -sTCP:LISTEN -nP` näitab `mariadbd` kuulamas `127.0.0.1:3307`; `SHOW VARIABLES` kinnitab `port = 3307` |
| Teine MySQL ei sega | minu varasem server käib **3306** peal, uus **3307** peal — mõlemad töötavad samaaegselt, portidel konflikti pole |
| Sakila | `sakila-db.tar.gz` allalaaditud ametlikult aadressilt `downloads.mysql.com`, laetud `sakila-schema.sql` + `sakila-data.sql` |
| Workbenchi kasutaja | `mysql` / `mysql`, `GRANT ALL ... WITH GRANT OPTION`; sisselogimine TCP kaudu `127.0.0.1:3307` (nagu Workbench teeb) |

Sakila sisu: 200 näitlejat, 1000 filmi, 599 klienti, 16 044 renti ja makset, 4581 inventari
ühikut. Kontrollpäringud: enim renditud film *Bucket Brotherhood* (34), enim maksnud klient
*Karl Seal* (221,55).

## Kaks kõrvalekallet ülesandest

**`bind-address = 127.0.0.1`, mitte `0.0.0.0`.** Ülesandes oli `0.0.0.0`, aga see teeb andmebaasi
kättesaadavaks igalt poolt võrgust, ja kasutaja `mysql` parool on `mysql`. Panin serveri
kuulama ainult kohalikule arvutile — Workbench samas arvutis ühendub ikka.

**WSL / Ubuntu / Workbench puuduvad.** Minu arvuti on Mac, seega `systemctl`, `/etc/mysql/…`
ja Workbench asenduvad vastavalt `ps`-i, seadistusfaili `my3307.cnf` ja TCP-ühendusega
`mariadb -h 127.0.0.1 -P 3307`. Põhjendus on sama, mis varasemates töödes (2026-01-15, 2026-01-22).
