# -*- coding: utf-8 -*-
"""
KOLMAS ULESANNE - lihtne pangaandmebaas (3 klienti, igal 3 arvet)
Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2025-12-09 "Mysql, Redis, Mongodb, Excel")

Nouded:
  * kolm klienti, igal kliendil kolm arvet
  * arvete tuubid: arveldusarve, saastuhoius, tahtajaline hoius
  * klient: isikukood, eesnimi, perekonnanimi
  * arve: tuup, kellele kuulub, kontojaak
  * NB! uks klient peate olema Teie ise
Tehtud nelja kohas: MySQL (MariaDB), Redis, MongoDB, Excel.
"""
import datetime as dt
from decimal import Decimal
import pymysql, redis, pymongo
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill
from openpyxl.utils import get_column_letter

joon = lambda t: print("\n" + t + "\n" + "-" * 78)
TUUBID = [("CURR", "arveldusarve"), ("SAVE", "saastuhoius"), ("TERM", "tahtajaline hoius")]
KLIENDID = [  # isikukood, eesnimi, perekonnanimi
    (50603142719, "Jegor", "Onoprijuk"),      # <- mina ise
    (49001010011, "Mari",  "Tamm"),
    (38505050022, "Jaan",  "Kask"),
]
ARVED = [  # arvenumber, tuup, klient, kontojaak
    (100100, "CURR", 50603142719,  2500.00), (100101, "SAVE", 50603142719,  8000.00), (100102, "TERM", 50603142719, 15000.00),
    (100200, "CURR", 49001010011,  1200.50), (100201, "SAVE", 49001010011,  4300.00), (100202, "TERM", 49001010011, 10000.00),
    (100300, "CURR", 38505050022,   310.75), (100301, "SAVE", 38505050022, 22000.00), (100302, "TERM", 38505050022, 50000.00),
]
TYYP = dict(TUUBID)
nimi = {i: f"{e} {p}" for i, e, p in KLIENDID}

print("=" * 78)
print("PANGAANDMEBAAS - nelja andmebaasiga (MySQL, Redis, MongoDB, Excel)")
print("Jegor Onoprijuk, ruhm TA-24B")
print("=" * 78)

# ===================================================================== MYSQL
joon("1) MYSQL (MariaDB)")
con = pymysql.connect(unix_socket="/tmp/maria.sock", user="root", charset="utf8mb4", autocommit=False)
cur = con.cursor()
cur.execute("DROP DATABASE IF EXISTS pank_1209"); cur.execute("CREATE DATABASE pank_1209 CHARACTER SET utf8mb4"); cur.execute("USE pank_1209")
cur.execute("CREATE TABLE customer (idcode BIGINT UNSIGNED PRIMARY KEY, firstname VARCHAR(64) NOT NULL, lastname VARCHAR(64) NOT NULL)")
cur.execute("CREATE TABLE accounttype (type CHAR(4) PRIMARY KEY, description VARCHAR(40) NOT NULL)")
cur.execute("""CREATE TABLE account (
    accountnumber BIGINT UNSIGNED PRIMARY KEY, accounttype CHAR(4) NOT NULL,
    customerid BIGINT UNSIGNED NOT NULL, balance DECIMAL(12,2) NOT NULL,
    CHECK (balance >= 0),                                    -- miinusesse minna ei saa
    FOREIGN KEY (accounttype) REFERENCES accounttype(type),
    FOREIGN KEY (customerid)  REFERENCES customer(idcode))""")
cur.executemany("INSERT INTO accounttype VALUES (%s,%s)", TUUBID)
cur.executemany("INSERT INTO customer VALUES (%s,%s,%s)", KLIENDID)
cur.executemany("INSERT INTO account VALUES (%s,%s,%s,%s)", ARVED); con.commit()
cur.execute("""SELECT CONCAT(c.firstname,' ',c.lastname), t.description, a.accountnumber, a.balance
               FROM account a JOIN customer c ON c.idcode=a.customerid JOIN accounttype t ON t.type=a.accounttype
               ORDER BY a.accountnumber""")
print(f"{'klient':<18}{'arve tuup':<20}{'arve nr':<9}{'jaak':>10}")
for r in cur.fetchall(): print(f"{r[0]:<18}{r[1]:<20}{r[2]:<9}{r[3]:>10}")
cur.execute("""SELECT CONCAT(c.firstname,' ',c.lastname), COUNT(*), SUM(a.balance)
               FROM customer c JOIN account a ON a.customerid=c.idcode GROUP BY c.idcode ORDER BY 3 DESC""")
print("\nklientide kontojaagid kokku:")
for r in cur.fetchall(): print(f"   {r[0]:<18}{r[1]} arvet   {r[2]:>10}")
# --- tehing: ule kandmine (ACID)
print("\nULEKANNE 500 EUR: Jegor arveldusarve -> saastuhoius (tehing)")
cur.execute("UPDATE account SET balance = balance - 500 WHERE accountnumber = 100100")
cur.execute("UPDATE account SET balance = balance + 500 WHERE accountnumber = 100101"); con.commit()
cur.execute("SELECT accountnumber, balance FROM account WHERE customerid=50603142719 ORDER BY 1"); print("  ", cur.fetchall())
print("KATSE: 99999 EUR arveldusarvelt (ei jata, CHECK + ROLLBACK)")
try:
    cur.execute("UPDATE account SET balance = balance - 99999 WHERE accountnumber = 100100"); con.commit()
except Exception as e:
    con.rollback(); print("   viga:", str(e)[:70], "-> ROLLBACK")
cur.execute("SELECT accountnumber, balance FROM account WHERE customerid=50603142719 ORDER BY 1"); print("   jaagid alles samad:", cur.fetchall())
con.close()

# ===================================================================== REDIS
joon("2) REDIS")
r = redis.Redis(host="127.0.0.1", port=6379, decode_responses=True)
for k in r.scan_iter("pank:*"): r.delete(k)
for i, e, p in KLIENDID: r.hset(f"pank:customer:{i}", mapping={"firstname": e, "lastname": p})
for n, t, c, b in ARVED:
    r.hset(f"pank:account:{n}", mapping={"type": t, "customer": c, "balance": b})
    r.sadd(f"pank:customer:{c}:accounts", n)            # klient -> tema arved
for i, e, p in KLIENDID:
    nrs = sorted(r.smembers(f"pank:customer:{i}:accounts"), key=int)
    kokku = sum(float(r.hget(f"pank:account:{n}", "balance")) for n in nrs)
    print(f"{e + ' ' + p:<18}{len(nrs)} arvet: {', '.join(nrs)}   kokku {kokku:.2f}")
print("\nULEKANNE 500 EUR (WATCH + MULTI/EXEC - Redise tehing, ilma CHECK-ita)")
with r.pipeline() as p:
    p.watch("pank:account:100100")
    jaak = float(p.hget("pank:account:100100", "balance"))
    p.multi()
    p.hincrbyfloat("pank:account:100100", "balance", -500); p.hincrbyfloat("pank:account:100101", "balance", 500)
    p.execute()
print("   jaagid:", r.hget("pank:account:100100", "balance"), "/", r.hget("pank:account:100101", "balance"))
print("   NB! Redis ei kontrolli, et jaak ei lahe miinusesse - seda peab tegema rakendus ise.")

# =================================================================== MONGODB
joon("3) MONGODB")
mc = pymongo.MongoClient("mongodb://127.0.0.1:27017"); mdb = mc["pank"]
mdb.customers.delete_many({})
for i, e, p in KLIENDID:       # arved on kliendi dokumendi SEES (embedded)
    mdb.customers.insert_one({"_id": i, "firstname": e, "lastname": p,
        "accounts": [{"accountnumber": n, "type": TYYP[t], "balance": b} for n, t, c, b in ARVED if c == i]})
for d in mdb.customers.find().sort("_id"):
    print(f"{d['firstname'] + ' ' + d['lastname']:<18}{len(d['accounts'])} arvet  kokku {sum(a['balance'] for a in d['accounts']):.2f}")
print("\nagregatsioon: arvete tuupide kokkusummad")
for x in mdb.customers.aggregate([{"$unwind": "$accounts"}, {"$group": {"_id": "$accounts.type", "kokku": {"$sum": "$accounts.balance"}}}, {"$sort": {"kokku": -1}}]):
    print(f"   {x['_id']:<20}{x['kokku']:>10.2f}")
print("\nTEHING (ulekanne) - katse MongoDB-s:")
try:
    with mc.start_session() as s:
        with s.start_transaction():
            mdb.customers.update_one({"_id": 50603142719, "accounts.accountnumber": 100100}, {"$inc": {"accounts.$.balance": -500}}, session=s)
    print("   onnestus")
except Exception as e:
    print("   viga:", str(e)[:95]); print("   -> uhe dokumendi sees on uuendus aatomiline, aga mitme dokumendi tehing vajab replica set'i.")

# ===================================================================== EXCEL
joon("4) EXCEL")
wb = Workbook(); w1 = wb.active; w1.title = "Kliendid"; w2 = wb.create_sheet("Kontotuubid"); w3 = wb.create_sheet("Arved")
H, F = Font(bold=True, color="FFFFFF"), PatternFill("solid", fgColor="0B5CFF")
def tab(ws, hdr, rows):
    ws.append(hdr)
    for c in ws[1]: c.font, c.fill = H, F
    for r_ in rows: ws.append(r_)
tab(w1, ["isikukood", "eesnimi", "perekonnanimi", "arvete arv", "kontojaak kokku"], KLIENDID)
for i in range(2, 5):
    w1[f"D{i}"] = f"=COUNTIF(Arved!$C$2:$C$10,A{i})"; w1[f"E{i}"] = f"=SUMIF(Arved!$C$2:$C$10,A{i},Arved!$D$2:$D$10)"
tab(w2, ["type", "description"], TUUBID)
tab(w3, ["arvenumber", "tuup", "kliendi isikukood", "kontojaak", "klient"], [(n, t, c, b) for n, t, c, b in ARVED])
for i in range(2, 11):
    w3[f"E{i}"] = f"=VLOOKUP(C{i},Kliendid!$A$2:$C$4,2,FALSE)&\" \"&VLOOKUP(C{i},Kliendid!$A$2:$C$4,3,FALSE)"
w3["G1"], w3["G2"] = "Kontojaak kokku (koik arved)", "=SUM(D2:D10)"
w3["G4"] = "Jegor Onoprijuk, TA-24B"; w3["G4"].font = Font(bold=True)
for ws in (w1, w2, w3):
    for col in range(1, ws.max_column + 1): ws.column_dimensions[get_column_letter(col)].width = 26
wb.save("pank.xlsx"); print("salvestatud: pank.xlsx (3 lehte; COUNTIF/SUMIF/VLOOKUP valemid)")

joon("5) MILLINE ANDMEBAAS ON SELLE ULESANDE JAOKS PARIM?")
print("""Raha ja kontojaagid - siin on koige olulisem KORRAKTUS ja TEHINGUD:

  MySQL    - PARIM. ACID tehingud: ulekanne on kas tervikuna tehtud voi mitte. CHECK
             (balance >= 0) ei lase konto miinusesse minna, valisvoti ei lase luua arvet
             olematule kliendile. Logis: 99999 EUR katse sai ROLLBACK-i ja jaagid jaid samaks.
  MongoDB  - SOBIB TAIENDAVAKS. Arved kliendi dokumendi sees muudab lugemise lihtsaks, aga
             tehing mitme dokumendi vahel vajab replica set'i (logis nahtav viga), ja
             skeemi kontrolli (nt jaak >= 0) peab ise lisama.
  Redis    - EI SOBI PEAANDMEBAASIKS. Kiire ja MULTI/EXEC annab tehingu, aga ei kontrolli
             jaake, vaikimisi ei pruugi andmed kettale jaada, ja seoseid peab ise hoidma
             (klient -> arved SET-idega). Sobiks vahemalluks (nt "kontojaak praegu").
  Excel    - EI SOBI. Pole tehinguid, pole mitme kasutaja kaitset, pole valisvotmeid.
             SUMIF/VLOOKUP naitavad kenasti kokkuvotet, aga sobib aruandeks, mitte panga
             andmebaasiks.""")
