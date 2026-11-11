# -*- coding: utf-8 -*-
"""
ESIMENE ULESANNE - noiajoogid (mang toimib reaalajas)
Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2025-12-09 "Mysql, Redis, Mongodb, Excel")

Nouded:
  * noia kohta nimi ja tase (name, level)
  * jook - tuup ja ajad (type, productiontime, expirationtime)
  * jooki valmistamine votab aega, valmis jook sailib mone aja
  * joogi valmimise ja aegumise hetk soltub reaalajast, sellest, millal noid
    joogi valmistamist alustas
  * parast sailivusaja loppu voib jook andmebaasi alles jaada, kuid ei pea

Sama andmemudel tehtud NELJAS kohas: MySQL (MariaDB), Redis, MongoDB, Excel.
"""
import datetime as dt
import json, sys
import pymysql, redis, pymongo
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill, Alignment
from openpyxl.utils import get_column_letter

NOW = dt.datetime.now().replace(microsecond=0)
M = lambda minutes: dt.timedelta(minutes=minutes)
joon = lambda t: print("\n" + t + "\n" + "-" * 78)

# ------------------------------------------------------------ andmed
NOIAD = [  # id, name, level
    (1, "Jegor Onoprijuk", 7),
    (2, "Morgana",         9),
    (3, "Hildegard",       4),
    (4, "Baba Jaga",      10),
]
TUUBID = [  # type, productiontime (min), expirationtime (min)
    ("elujook",            5,  120),   # valmib 5 min, sailib 2 tundi
    ("murk",              60,  720),   # valmib 1 tund, sailib 12 tundi
    ("nahtamatuks tegev", 15,   90),   # valmib 15 min, sailib 90 min
    ("kiirusejook",       10,  240),
]
# noid, joogi tuup, millal alustas (NOW suhtes, minutites tagasi)
VALMISTAMISED = [
    (1, "elujook",            -3),     # alles valmib (jaab 2 min)
    (1, "nahtamatuks tegev", -40),     # valmis, sailib veel
    (2, "murk",              -30),     # valmib alles 30 min parast
    (2, "elujook",           -300),    # AEGUNUD (valmis 295 min tagasi, sailib 120)
    (3, "kiirusejook",       -12),     # valmis 2 min tagasi
    (3, "murk",              -900),    # AEGUNUD
    (4, "nahtamatuks tegev",  -1),     # valmib 14 min parast
    (4, "elujook",           -100),    # valmis, sailib veel 25 min
]
TUUP = {t: (p, e) for t, p, e in TUUBID}
def ajad(tuup, alustas_min):
    p, e = TUUP[tuup]
    algus = NOW + M(alustas_min)
    valmis = algus + M(p)
    aegub = valmis + M(e)
    return algus, valmis, aegub
def staatus(valmis, aegub, nuud=NOW):
    return "aegunud" if nuud >= aegub else ("valmis" if nuud >= valmis else "valmistamisel")

READY = []
for i, (noid, tuup, a) in enumerate(VALMISTAMISED, 1):
    algus, valmis, aegub = ajad(tuup, a)
    READY.append(dict(id=i, noid=noid, tuup=tuup, algus=algus, valmis=valmis, aegub=aegub))

print("=" * 78)
print("NOIAJOOGID - nelja andmebaasiga (MySQL, Redis, MongoDB, Excel)")
print("Jegor Onoprijuk, ruhm TA-24B")
print(f"mangu 'praegu' = {NOW:%d.%m.%Y %H:%M:%S}")
print("=" * 78)

# ===================================================================== MYSQL
joon("1) MYSQL (MariaDB)")
con = pymysql.connect(unix_socket="/tmp/maria.sock", user="root", charset="utf8mb4", autocommit=True)
cur = con.cursor()
cur.execute("DROP DATABASE IF EXISTS noiajoogid_1209")
cur.execute("CREATE DATABASE noiajoogid_1209 CHARACTER SET utf8mb4")
cur.execute("USE noiajoogid_1209")
cur.execute("""CREATE TABLE witch (
    id INT PRIMARY KEY, name VARCHAR(80) NOT NULL, level TINYINT NOT NULL)""")
cur.execute("""CREATE TABLE potiontype (
    type VARCHAR(40) PRIMARY KEY,
    productiontime INT NOT NULL COMMENT 'minutit',
    expirationtime INT NOT NULL COMMENT 'minutit parast valmimist')""")
# Valmimise ja aegumise aeg ARVUTATAKSE, neid ei hoita ega pea kellegi kasitsi uuendama.
cur.execute("""CREATE TABLE brew (
    id INT PRIMARY KEY, witch_id INT NOT NULL, type VARCHAR(40) NOT NULL,
    started_at DATETIME NOT NULL,
    FOREIGN KEY (witch_id) REFERENCES witch(id), FOREIGN KEY (type) REFERENCES potiontype(type))""")
cur.execute("""CREATE VIEW potion AS
    SELECT b.id, w.name AS witch, b.type, b.started_at,
           b.started_at + INTERVAL t.productiontime MINUTE AS ready_at,
           b.started_at + INTERVAL (t.productiontime + t.expirationtime) MINUTE AS expires_at,
           CASE WHEN NOW() >= b.started_at + INTERVAL (t.productiontime + t.expirationtime) MINUTE THEN 'aegunud'
                WHEN NOW() >= b.started_at + INTERVAL t.productiontime MINUTE THEN 'valmis'
                ELSE 'valmistamisel' END AS status
    FROM brew b JOIN witch w ON w.id = b.witch_id JOIN potiontype t ON t.type = b.type""")
cur.executemany("INSERT INTO witch VALUES (%s,%s,%s)", NOIAD)
cur.executemany("INSERT INTO potiontype VALUES (%s,%s,%s)", TUUBID)
cur.executemany("INSERT INTO brew VALUES (%s,%s,%s,%s)", [(r["id"], r["noid"], r["tuup"], r["algus"]) for r in READY])
cur.execute("SELECT id, witch, type, DATE_FORMAT(started_at,'%H:%i') alustas, DATE_FORMAT(ready_at,'%H:%i') valmis, DATE_FORMAT(expires_at,'%H:%i') aegub, status FROM potion ORDER BY id")
print(f"{'id':<3}{'noid':<18}{'jook':<20}{'alustas':<9}{'valmis':<8}{'aegub':<8}staatus")
for r in cur.fetchall(): print(f"{r[0]:<3}{r[1]:<18}{r[2]:<20}{r[3]:<9}{r[4]:<8}{r[5]:<8}{r[6]}")
cur.execute("SELECT status, COUNT(*) FROM potion GROUP BY status ORDER BY 1")
print("\nkokkuvote:", dict(cur.fetchall()))
cur.execute("SELECT witch, type FROM potion WHERE status = 'valmis' ORDER BY witch")
print("praegu VALMIS (voib kasutada):", [f"{a} - {b}" for a, b in cur.fetchall()])
cur.execute("SELECT witch, type, TIMESTAMPDIFF(MINUTE, NOW(), ready_at) FROM potion WHERE status='valmistamisel' ORDER BY ready_at")
print("alles VALMISTAMISEL:", [f"{a} - {b} (veel {c} min)" for a, b, c in cur.fetchall()])
mysql_rows = None

# ===================================================================== REDIS
joon("2) REDIS")
r = redis.Redis(host="127.0.0.1", port=6379, decode_responses=True)
for k in r.scan_iter("noiajoogid:*"): r.delete(k)
for nid, name, lvl in NOIAD:
    r.hset(f"noiajoogid:witch:{nid}", mapping={"name": name, "level": lvl})
for t, p, e in TUUBID:
    r.hset(f"noiajoogid:type:{t}", mapping={"productiontime": p, "expirationtime": e})
for b in READY:
    key = f"noiajoogid:brew:{b['id']}"
    r.hset(key, mapping={"witch_id": b["noid"], "type": b["tuup"],
                          "started_at": int(b["algus"].timestamp()),
                          "ready_at": int(b["valmis"].timestamp()),
                          "expires_at": int(b["aegub"].timestamp())})
    r.zadd("noiajoogid:ready_at", {key: int(b["valmis"].timestamp())})     # millal valmib
    r.zadd("noiajoogid:expires_at", {key: int(b["aegub"].timestamp())})    # millal aegub
    # *** Redise eelis: aegumine ise! Joogi voti kustub ISE parast aegumist (TTL)
    ttl = int((b["aegub"] - NOW).total_seconds())
    if ttl > 0:
        r.expire(key, ttl)
    else:
        r.delete(key)                       # juba aegunud -> Redis ei hoiagi enam
        r.zrem("noiajoogid:ready_at", key); r.zrem("noiajoogid:expires_at", key)
nowts = int(NOW.timestamp())
print("TTL-iga voti: aegunud joogid on Redisest kadunud, ise.")
print(f"joogivotmeid alles: {len(list(r.scan_iter('noiajoogid:brew:*')))} (8-st, 2 aegunud on kustutatud)")
valmis = [k for k in r.zrangebyscore("noiajoogid:ready_at", "-inf", nowts)]
print("praegu VALMIS (ready_at <= now, ZRANGEBYSCORE):")
for k in valmis:
    h = r.hgetall(k); print(f"   {r.hget('noiajoogid:witch:%s' % h['witch_id'], 'name'):<18}{h['type']:<20} TTL {r.ttl(k)} s")
valm = r.zrangebyscore("noiajoogid:ready_at", nowts + 1, "+inf", withscores=True)
print("alles VALMISTAMISEL:")
for k, s in valm:
    h = r.hgetall(k); print(f"   {r.hget('noiajoogid:witch:%s' % h['witch_id'], 'name'):<18}{h['type']:<20} veel {int((s - nowts) / 60)} min")
# demo: lyhike TTL naitab, et "aegub" toimib ka reaalajas
r.hset("noiajoogid:demo", mapping={"type": "demo-jook (TTL 2 s)"}); r.expire("noiajoogid:demo", 2)
import time; print("\ndemo-jook enne aegumist:", r.exists("noiajoogid:demo"), end="  ->  "); time.sleep(2.2)
print("parast 2 sekundit:", r.exists("noiajoogid:demo"))

# =================================================================== MONGODB
joon("3) MONGODB")
mc = pymongo.MongoClient("mongodb://127.0.0.1:27017"); mdb = mc["noiajoogid"]
for c in ("witches", "potiontypes", "brews"): mdb[c].delete_many({})
mdb.witches.insert_many([{"_id": i, "name": n, "level": l} for i, n, l in NOIAD])
mdb.potiontypes.insert_many([{"_id": t, "productiontime": p, "expirationtime": e} for t, p, e in TUUBID])
mdb.brews.insert_many([{"_id": b["id"], "witch_id": b["noid"], "type": b["tuup"], "started_at": b["algus"],
                         "ready_at": b["valmis"], "expires_at": b["aegub"]} for b in READY])
# TTL indeks: MongoDB kustutab dokumendi ise, kui expires_at on moodas (taustaprotsess, ~60 s vahega)
mdb.brews.create_index("expires_at", expireAfterSeconds=0)
print("indeksid brews kollektsioonil:", {k: v for k, v in mdb.brews.index_information().items() if k != "_id_"})
for st, filt in (("VALMIS", {"ready_at": {"$lte": NOW}, "expires_at": {"$gt": NOW}}),
                 ("VALMISTAMISEL", {"ready_at": {"$gt": NOW}}),
                 ("AEGUNUD", {"expires_at": {"$lte": NOW}})):
    docs = list(mdb.brews.find(filt).sort("_id"))
    print(f"{st}: {len(docs)}")
    for d in docs:
        w = mdb.witches.find_one({"_id": d["witch_id"]})["name"]
        print(f"   {w:<18}{d['type']:<20}valmib {d['ready_at']:%H:%M}  aegub {d['expires_at']:%H:%M}")
print("agregatsioon: mitu jooki noia kohta ->",
      {x["_id"]: x["n"] for x in mdb.brews.aggregate([{"$group": {"_id": "$witch_id", "n": {"$sum": 1}}}, {"$sort": {"_id": 1}}])})

# ===================================================================== EXCEL
joon("4) EXCEL")
wb = Workbook()
ws0 = wb.active; ws0.title = "Noiad"
ws1 = wb.create_sheet("Joogituubid"); ws2 = wb.create_sheet("Joogid")
head = Font(bold=True, color="FFFFFF"); fill = PatternFill("solid", fgColor="0B5CFF")
def tabel(ws, hdr, rows):
    ws.append(hdr)
    for c in ws[1]: c.font, c.fill = head, fill
    for row in rows: ws.append(row)
tabel(ws0, ["id", "name", "level"], NOIAD)
tabel(ws1, ["type", "productiontime (min)", "expirationtime (min)"], TUUBID)
tabel(ws2, ["id", "noid (name)", "type", "alustas", "valmis (arvutatud)", "aegub (arvutatud)", "staatus (arvutatud)"], [])
for i, b in enumerate(READY, start=2):
    ws2.append([b["id"], None, b["tuup"], b["algus"], None, None, None])
    # valemid: nimi VLOOKUP-iga, ajad = alustas + minutid/1440, staatus IF-iga reaalajas (NOW())
    ws2[f"B{i}"] = f"=VLOOKUP({b['noid']},Noiad!$A$2:$B$5,2,FALSE)"
    ws2[f"E{i}"] = f"=D{i}+VLOOKUP(C{i},Joogituubid!$A$2:$C$5,2,FALSE)/1440"
    ws2[f"F{i}"] = f"=E{i}+VLOOKUP(C{i},Joogituubid!$A$2:$C$5,3,FALSE)/1440"
    ws2[f"G{i}"] = f'=IF(NOW()>=F{i},"aegunud",IF(NOW()>=E{i},"valmis","valmistamisel"))'
for c in ws2[1]: c.font, c.fill = head, fill
for row in ws2.iter_rows(min_row=2, min_col=4, max_col=6):
    for c in row: c.number_format = "dd.mm.yyyy hh:mm"
for ws in (ws0, ws1, ws2):
    for col in range(1, ws.max_column + 1):
        ws.column_dimensions[get_column_letter(col)].width = 24
ws2["I1"], ws2["J1"] = "staatus", "mitu"
for k, s in enumerate(("valmistamisel", "valmis", "aegunud"), start=2):
    ws2[f"I{k}"] = s; ws2[f"J{k}"] = f'=COUNTIF($G$2:$G$9,I{k})'
ws2["I6"] = "Jegor Onoprijuk, TA-24B"; ws2["I6"].font = Font(bold=True)
wb.save("noiajoogid.xlsx")
print("salvestatud: noiajoogid.xlsx (3 lehte; valemid arvutavad ajad ja staatuse; NOW() muudab staatust reaalajas)")
print("valemid: valmis = alustas + productiontime/1440 ; aegub = valmis + expirationtime/1440")

# ===================================================================== JARELDUS
joon("5) MILLINE ANDMEBAAS ON SELLE ULESANDE JAOKS PARIM?")
print("""Reaalajas aegumine on siin kesksel kohal, ja just see eristab andmebaase:

  Redis    - PARIM. Iga joogi votmele paneb EXPIRE, ja jook kaob ISE oigel hetkel, mingit
             puhastuskoodi ei ole vaja. ZSET (ready_at / expires_at) annab "mis on praegu
             valmis" uhe paringuga. Mang on reaalajas, Redis on moeldud mallu ja ajastuse jaoks.
  MongoDB  - HEA. TTL-indeks kustutab aegunud dokumendi ise, ainult mitte sekundi
             tapsusega (taustaprotsess kaib umbes kord minutis). Dokumendimudel sobib mangu
             jaoks, kus joogil voivad tulevikus olla uued valjad.
  MySQL    - TOOTAB, aga aegumist ise ei tee. Aegunud read jaavad tabelisse, kuni neid keegi
             kustutab (EVENT voi cron). Moistlik lahendus on arvutada staatus vaates (nagu ma
             tegin), mitte hoida seda tulbas.
  Excel    - ESIMENE VALIK POLE. Valemid + NOW() naitavad staatust, aga see uueneb alles faili
             avamisel/arvutamisel, mitu mangijat korraga ei saa, ja mang ei saa ise Excelit
             "kusida". Sobib prototuubiks voi aruandeks, mitte mangu andmebaasiks.""")
con.close()
