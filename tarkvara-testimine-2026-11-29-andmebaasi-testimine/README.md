# Andmebaasi testimine (shop-database.sql)

**Autor:** Jegor Onoprijuk, TA-24B  
**Aine:** Tarkvara testimise alused (2026)  
**Ülesanne:** Tunnitöö/Kodutöö: Andmebaasi testimine

Käivitasin faili `shop-database.sql` SQLite'is (sqlite3 3.51, samad päringud töötavad ka sqliteonline.com-is) ja kirjutasin igale nõudele ühe päringu. Hea kontrollpäring tagastab nullread, kui nõue on täidetud, ja rikkuvad read, kui nõue on rikutud. Kõik päringud on failis [`paringud.sql`](paringud.sql), nende väljund on failis [`valjund.txt`](valjund.txt) (ekraanipilt: `valjund.png`).

## 1. Päring iga nõude kohta

| Nõue | Päring | Tulemus |
|---|---|---|
| R1 – kliendil on e-post | `SELECT id, name, email FROM customers WHERE email IS NULL OR TRIM(email) = '';` | 1 rida (klient 4) |
| R2 – tellimus kuulub olemasolevale kliendile | `SELECT o.id, o.customer_id FROM orders o LEFT JOIN customers c ON c.id = o.customer_id WHERE c.id IS NULL;` | 1 rida (tellimus 103) |
| R3 – kogus vähemalt 1 | `SELECT * FROM order_items WHERE quantity IS NULL OR quantity < 1;` | 1 rida (rida 1006) |
| R4 – hind suurem kui 0 | `SELECT * FROM products WHERE price IS NULL OR price <= 0;` | 1 rida (toode 15) |
| R5 – staatus NEW/PAID/SHIPPED/CANCELLED | `SELECT * FROM orders WHERE status IS NULL OR status NOT IN ('NEW','PAID','SHIPPED','CANCELLED');` | 1 rida (tellimus 105) |
| R6 – tellimus pole tulevikus | `SELECT * FROM orders WHERE created_at > datetime('now');` | 1 rida (tellimus 106) |
| R7 – tellimuse summa = ridade summa | `SELECT o.id, o.total, ROUND(SUM(i.quantity*i.unit_price),2) FROM orders o JOIN order_items i ON i.order_id=o.id GROUP BY o.id, o.total HAVING o.total <> ROUND(SUM(i.quantity*i.unit_price),2);` | 1 rida (tellimus 100) |

## 2. JOIN vs LEFT JOIN (orders ja customers)

| Päring | Ridu |
|---|---|
| `orders JOIN customers` (INNER JOIN) | **7** |
| `orders LEFT JOIN customers` | **8** |

Tabelis `orders` on 8 tellimust. INNER JOIN jätab alles ainult need read, millele leidub paar teises tabelis. Tellimusel 103 on `customer_id = 99`, aga sellist klienti ei ole, seega INNER JOIN viskab selle rea vaikselt välja ja aruanne näitab ühe tellimuse vähem. LEFT JOIN jätab kõik tellimused alles ja puuduva kliendi veerud on NULL. Erinevus ühe rea võrra **ongi defekt** (R2): andmetes on "orb-tellimus".

## 3. Leitud defektid

| # | Defekt | Leidnud päring | Read | Rikutud nõue | Tõsidus | Mis oleks selle ära hoidnud |
|---|---|---|---|---|---|---|
| 1 | Kliendil Jaan Saar (id 4) puudub e-post | R1 päring | `customers.id = 4` | R1 | Keskmine – kliendile ei saa kinnitust ega arvet saata, kuid tellimusi see ei riku | `NOT NULL` veerul `email` (lisaks `CHECK (email LIKE '%_@_%')`) |
| 2 | Tellimus 103 viitab olematule kliendile 99 | R2 päring (LEFT JOIN) | `orders.id = 103` | R2 | Kõrge – tellimus on makstud (PAID) aga omanikuta, INNER JOIN aruanded kaotavad selle | `FOREIGN KEY (customer_id) REFERENCES customers(id)` (SQLite'is `PRAGMA foreign_keys = ON`) |
| 3 | Tellimuse rea 1006 kogus on -1 | R3 päring | `order_items.id = 1006` (tellimus 104) | R3 | Kõrge – negatiivne kogus peidab tagasimakse/korrektuuri tavalise tellimuse sees ja moonutab summasid | `CHECK (quantity >= 1)` |
| 4 | Toote "Webcam" (id 15) hind on 0.00 ja toode on aktiivne | R4 päring | `products.id = 15` | R4 | Keskmine kuni kõrge – toodet saaks tasuta osta | `CHECK (price > 0)` |
| 5 | Tellimuse 105 staatus on `PAYED` (kirjaviga, peaks olema `PAID`) | R5 päring | `orders.id = 105` | R5 | Keskmine – tellimus langeb staatuse järgi filtreerimisel välja (nt "kõik makstud tellimused") | `CHECK (status IN ('NEW','PAID','SHIPPED','CANCELLED'))` või eraldi staatuste tabel + FK |
| 6 | Tellimuse 106 kuupäev on 2062-03-10 (tõenäoliselt kirjaviga, peaks olema 2026) | R6 päring | `orders.id = 106` | R6 | Keskmine – aruanded ja kuupõhised filtrid ei näita tellimust õigel ajal | Lihtsad piirangud ei aita (`CHECK` ei tohi kasutada `now()`); vaja **triggerit** või rakenduse/teenuse valideerimist |
| 7 | Tellimuse 100 `total` = 59.89, aga ridade summa on 69.89 (vahe 10.00) | R7 päring | `orders.id = 100` | R7 | Kõrge – rahasumma ei klapi, klient makstud valesti | Lihtsad piirangud ei aita: vaja triggerit, mis hoiab `total` kooskõlas, või mitte salvestada `total`-it üldse (arvutada vaates `SUM(quantity*unit_price)`), pluss automaattest |

Märkus: iga nõue on rikutud vähemalt korra (R1–R7 kõik leitud). Tellimus 104 näitab, kuidas defektid võivad üksteist varjata: selle `total` (179.05) klapib ridade summaga, sest negatiivne kogus (R3) lahutab 9.95 maha, seega R7 päring seda ei märka. Defekt tuli leida R3 päringuga.

## 4. Valikuline: R7 ilma ROUND-ita (tellimus 106)

Tellimusel 106 on üks rida: 6 × 9.95. Tellimuse `total` on 59.70.

- Ilma `ROUND`-ita on `SUM(quantity * unit_price)` ujukomaarv ja võrdlus `o.total = SUM(...)` annab tellimusel 106 tulemuse **0 (vale)**, kuigi mõlemad näivad olevat 59.7. Põhjus: 9.95 ei ole kahendsüsteemis täpselt esitatav ja 6 × 9.95 on ujukomaarvuna 59.699999999999996, mitte 59.7.
- `ROUND(..., 2)` korral on võrdlus täpne ja tellimus 106 ei ole R7 rikkuja (selle ainus viga on kuupäev, R6).

**Mida see tähendab rahaväärtuste testimisel:** raha ei tohi võrrelda ujukomaarvuna `=`-ga. Testis tuleb summa ümardada (`ROUND(x, 2)`) või võrrelda täisarvuna sentides (`CAST(ROUND(x*100) AS INTEGER)`), vastasel juhul tekivad valepositiivsed tulemused (test kukub, kuigi andmed on õiged) ja tegelikud rahavead võivad jääda märkamata. Andmebaasis tuleks rahaveergu hoida täisarvuna (sendid) või tegeliku `DECIMAL/NUMERIC` tüübina; SQLite'i `DECIMAL(10,2)` on tegelikult ujukomaarvu afiinsus ega taga täpsust.

## Failid

- `shop-database.sql` – õpetaja fail (muutmata)
- `paringud.sql` – minu päringud (R1–R7, JOIN vs LEFT JOIN)
- `valjund.txt` – päringute väljund
- `valjund.png` – ekraanipilt väljundist
