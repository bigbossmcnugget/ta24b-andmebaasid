# -*- coding: utf-8 -*-
"""
NELJAS ULESANNE - stock.zip: loe uks fail andmebaasi, leia millal kurss oli korgeim ja madalaim
Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2025-12-09 "Mysql, Redis, Mongodb, Excel")
Valitud firma: IBM  (IBM_daily_data.csv, 1980-12-11 ... 2024-09-27, 11041 paeva)
"Kurss" = sulgemishind (Close). Lisaks naitan paeva siseselt korgeimat (High) ja madalaimat (Low).
"""
import csv
import pymysql, redis, pymongo
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill
from openpyxl.utils import get_column_letter

FIRMA, FAIL = "IBM", "stock_data/stock/IBM_daily_data.csv"
joon = lambda t: print("\n" + t + "\n" + "-" * 78)
ROWS = []
with open(FAIL, newline="") as f:
    for r in csv.DictReader(f):
        ROWS.append(dict(date=r["Date"], open=float(r["Open"]), high=float(r["High"]), low=float(r["Low"]),
                         close=float(r["Close"]), adjclose=float(r["Adj Close"]), volume=int(r["Volume"])))
print("=" * 78); print(f"AKTSIAKURSS {FIRMA} - lugemine nelja andmebaasi (MySQL, Redis, MongoDB, Excel)")
print("Jegor Onoprijuk, ruhm TA-24B"); print("=" * 78)
print(f"fail: {FAIL}   ridu: {len(ROWS)}   {ROWS[0]['date']} ... {ROWS[-1]['date']}")
hi = max(ROWS, key=lambda x: x["close"]); lo = min(ROWS, key=lambda x: x["close"])
print(f"kontroll Pythonis (tapne vastus): KORGEIM Close {hi['close']:.2f} kuupaeval {hi['date']};  MADALAIM Close {lo['close']:.4f} kuupaeval {lo['date']}")

# ===================================================================== MYSQL
joon("1) MYSQL (MariaDB)")
con = pymysql.connect(unix_socket="/tmp/maria.sock", user="root", charset="utf8mb4", autocommit=True); cur = con.cursor()
cur.execute("DROP DATABASE IF EXISTS aktsiad_1209"); cur.execute("CREATE DATABASE aktsiad_1209 CHARACTER SET utf8mb4"); cur.execute("USE aktsiad_1209")
cur.execute("""CREATE TABLE ibm (date DATE PRIMARY KEY, open DOUBLE, high DOUBLE, low DOUBLE, close DOUBLE,
               adjclose DOUBLE, volume BIGINT, INDEX (close))""")
cur.executemany("INSERT INTO ibm VALUES (%s,%s,%s,%s,%s,%s,%s)", [(x["date"], x["open"], x["high"], x["low"], x["close"], x["adjclose"], x["volume"]) for x in ROWS])
cur.execute("SELECT COUNT(*) FROM ibm"); print("ridu tabelis ibm:", cur.fetchone()[0])
cur.execute("SELECT date, close FROM ibm ORDER BY close DESC LIMIT 1"); a = cur.fetchone()
cur.execute("SELECT date, close FROM ibm ORDER BY close ASC LIMIT 1"); b = cur.fetchone()
print(f"\nSELECT date, close FROM ibm ORDER BY close DESC LIMIT 1;  ->  KORGEIM  {a[0]}  {a[1]:.2f}")
print(f"SELECT date, close FROM ibm ORDER BY close ASC  LIMIT 1;  ->  MADALAIM {b[0]}  {b[1]:.4f}")
cur.execute("SELECT date, high FROM ibm ORDER BY high DESC LIMIT 1"); c = cur.fetchone()
cur.execute("SELECT date, low FROM ibm ORDER BY low ASC LIMIT 1"); d = cur.fetchone()
print(f"paeva siseselt: korgeim High {c[1]:.2f} ({c[0]}),  madalaim Low {d[1]:.4f} ({d[0]})")
con.close()

# ===================================================================== REDIS
joon("2) REDIS")
r = redis.Redis(host="127.0.0.1", port=6379, decode_responses=True)
for k in r.scan_iter("aktsia:*"): r.delete(k)
p = r.pipeline()
for x in ROWS:
    p.hset(f"aktsia:IBM:{x['date']}", mapping=x)
    p.zadd("aktsia:IBM:close", {x["date"]: x["close"]})          # kuupaev -> sulgemishind
p.execute()
print("votmeid aktsia:IBM:<kuupaev>:", len(list(r.scan_iter("aktsia:IBM:*-*"))), "  sorted set aktsia:IBM:close:", r.zcard("aktsia:IBM:close"))
(dk, sk), = r.zrevrange("aktsia:IBM:close", 0, 0, withscores=True); (dm, sm), = r.zrange("aktsia:IBM:close", 0, 0, withscores=True)
print(f"\nZREVRANGE aktsia:IBM:close 0 0 WITHSCORES  ->  KORGEIM  {dk}  {sk:.2f}")
print(f"ZRANGE    aktsia:IBM:close 0 0 WITHSCORES  ->  MADALAIM {dm}  {sm:.4f}")

# =================================================================== MONGODB
joon("3) MONGODB")
mc = pymongo.MongoClient("mongodb://127.0.0.1:27017"); col = mc["aktsiad"]["ibm"]; col.delete_many({})
col.insert_many([dict(x, _id=x["date"]) for x in ROWS]); col.create_index("close")
print("dokumente kollektsioonis ibm:", col.count_documents({}))
a = col.find().sort("close", -1).limit(1)[0]; b = col.find().sort("close", 1).limit(1)[0]
print(f"\ndb.ibm.find().sort({{close:-1}}).limit(1)  ->  KORGEIM  {a['date']}  {a['close']:.2f}")
print(f"db.ibm.find().sort({{close: 1}}).limit(1)  ->  MADALAIM {b['date']}  {b['close']:.4f}")
print("agregatsioon: keskmine sulgemishind kumnendi kaupa (viimased 3):",
      [(x['_id'] + '0-ndad', round(x['avg'], 2)) for x in col.aggregate([{"$group": {"_id": {"$substr": ["$date", 0, 3]}, "avg": {"$avg": "$close"}}}, {"$sort": {"_id": 1}}])][-3:])

# ===================================================================== EXCEL
joon("4) EXCEL")
wb = Workbook(); ws = wb.active; ws.title = "IBM"
ws.append(["Date", "Open", "High", "Low", "Close", "Adj Close", "Volume"])
for c in ws[1]: c.font, c.fill = Font(bold=True, color="FFFFFF"), PatternFill("solid", fgColor="0B5CFF")
for x in ROWS: ws.append([x["date"], x["open"], x["high"], x["low"], x["close"], x["adjclose"], x["volume"]])
n = len(ROWS) + 1
ws["I1"], ws["J1"], ws["K1"] = "", "Kurss", "Kuupaev"
ws["I2"], ws["J2"], ws["K2"] = "KORGEIM (Close)", f"=MAX(E2:E{n})", f"=INDEX(A2:A{n},MATCH(J2,E2:E{n},0))"
ws["I3"], ws["J3"], ws["K3"] = "MADALAIM (Close)", f"=MIN(E2:E{n})", f"=INDEX(A2:A{n},MATCH(J3,E2:E{n},0))"
ws["I5"] = "Jegor Onoprijuk, TA-24B"; ws["I5"].font = Font(bold=True)
for col in range(1, 12): ws.column_dimensions[get_column_letter(col)].width = 20
wb.save("aktsia_IBM.xlsx"); print(f"salvestatud: aktsia_IBM.xlsx ({len(ROWS)} rida; valemid MAX/MIN + INDEX/MATCH)")

joon("5) MILLINE ANDMEBAAS ON SELLE ULESANDE JAOKS PARIM?")
print("""Ajaloolised aktsiakursid on klassikaline aegrida - suur hulk ridu, uks tabel, paringud
"korgeim / madalaim / keskmine perioodi kohta":

  MySQL    - PARIM. Kuupaev on PRIMARY KEY, close on indekseeritud, ORDER BY ... LIMIT 1 on
             kohene ka miljonite ridade korral; saab kohe kuskida perioodi, keskmist, liitumist
             teiste firmadega (iga firma oma tabel voi uks tabel firma veeruga).
  MongoDB  - HEA. Aegrida sobib dokumentidena ja agregatsioonid (keskmine kumnendi kaupa)
             on ilusad; MongoDB-l on olemas ka spetsiaalsed time-series kollektsioonid.
  Redis    - SOBIB UHE PARINGU JAOKS. Sorted set aktsia:IBM:close annab korgeima ja madalaima
             hetkega (ZREVRANGE/ZRANGE), aga kuupaevavahemiku, keskmise vms jaoks peaks
             lisaindekseid tegema; ja 11 tuhat hash'i mallu on raiskamine.
  Excel    - SOBIB (11 tuhat rida mahub vabalt): MAX/MIN + INDEX/MATCH annab vastuse ja graafiku
             saab kohe teha. Raskeks laheb, kui oleks kuue firma andmed 44 aasta kohta koos.""")
