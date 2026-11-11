# -*- coding: utf-8 -*-
"""
TEINE ULESANNE - imdbtitle.txt: loe fail koigisse nelja andmebaasi, leia koige pikem film
Jegor Onoprijuk, ruhm TA-24B   (ulesanne 2025-12-09 "Mysql, Redis, Mongodb, Excel")
Faili veerud (tab-eraldatud, puuduv vaartus = \\N): tconst, titleType, primaryTitle,
originalTitle, isAdult, startYear, endYear, runtimeMinutes, genres
"""
import csv
import pymysql, redis, pymongo
from openpyxl import Workbook
from openpyxl.styles import Font, PatternFill
from openpyxl.utils import get_column_letter

joon = lambda t: print("\n" + t + "\n" + "-" * 78)
def num(x): return None if x in ("\\N", "") else int(x)
def txt(x): return None if x == "\\N" else x
ROWS = []
with open("imdbtitle.txt", encoding="utf-8", newline="") as f:
    rd = csv.reader(f, delimiter="\t", quoting=csv.QUOTE_NONE)
    hdr = next(rd)
    for r in rd:
        if len(r) != 9: continue
        ROWS.append(dict(tconst=r[0], titleType=r[1], primaryTitle=r[2], originalTitle=r[3], isAdult=int(r[4]),
                         startYear=num(r[5]), endYear=num(r[6]), runtimeMinutes=num(r[7]), genres=txt(r[8])))
print("=" * 78); print("IMDB TITLE - lugemine nelja andmebaasi (MySQL, Redis, MongoDB, Excel)")
print("Jegor Onoprijuk, ruhm TA-24B"); print("=" * 78)
print(f"fail: imdbtitle.txt  veerud: {', '.join(hdr)}")
tuubid = {}
for x in ROWS: tuubid[x["titleType"]] = tuubid.get(x["titleType"], 0) + 1
print(f"ridu: {len(ROWS)}   tuubid: {tuubid}   runtimeMinutes puudub: {sum(1 for x in ROWS if x['runtimeMinutes'] is None)}")
ISE = max((x for x in ROWS if x["titleType"] == "movie" and x["runtimeMinutes"]), key=lambda x: x["runtimeMinutes"])
print(f"kontroll Pythonis (tapne vastus): koige pikem FILM (movie): {ISE['primaryTitle']} ({ISE['startYear']}) - {ISE['runtimeMinutes']} min")

# ===================================================================== MYSQL
joon("1) MYSQL (MariaDB)")
con = pymysql.connect(unix_socket="/tmp/maria.sock", user="root", charset="utf8mb4", autocommit=True); cur = con.cursor()
cur.execute("DROP DATABASE IF EXISTS imdb_1209"); cur.execute("CREATE DATABASE imdb_1209 CHARACTER SET utf8mb4"); cur.execute("USE imdb_1209")
cur.execute("""CREATE TABLE title (tconst VARCHAR(12) PRIMARY KEY, titleType VARCHAR(20), primaryTitle VARCHAR(255),
    originalTitle VARCHAR(255), isAdult TINYINT, startYear SMALLINT NULL, endYear SMALLINT NULL,
    runtimeMinutes INT NULL, genres VARCHAR(120) NULL, INDEX (runtimeMinutes))""")
cur.executemany("INSERT INTO title VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)",
    [(x["tconst"], x["titleType"], x["primaryTitle"], x["originalTitle"], x["isAdult"], x["startYear"], x["endYear"], x["runtimeMinutes"], x["genres"]) for x in ROWS])
cur.execute("SELECT COUNT(*) FROM title"); print("ridu tabelis title:", cur.fetchone()[0])
print("\nSELECT primaryTitle, startYear, runtimeMinutes FROM title WHERE titleType='movie' ORDER BY runtimeMinutes DESC LIMIT 3;")
cur.execute("SELECT primaryTitle, startYear, runtimeMinutes FROM title WHERE titleType='movie' ORDER BY runtimeMinutes DESC LIMIT 3")
for i, r in enumerate(cur.fetchall(), 1): print(f"   {i}. {r[0]} ({r[1]}) - {r[2]} min")
cur.execute("SELECT titleType, primaryTitle, runtimeMinutes FROM title ORDER BY runtimeMinutes DESC LIMIT 1")
print("koige pikem KOGU failis (koos luhifilmidega):", cur.fetchone())
con.close()

# ===================================================================== REDIS
joon("2) REDIS")
r = redis.Redis(host="127.0.0.1", port=6379, decode_responses=True)
for k in r.scan_iter("imdb:*"): r.delete(k)
p = r.pipeline()
for x in ROWS:
    p.hset(f"imdb:title:{x['tconst']}", mapping={k: ("" if v is None else v) for k, v in x.items()})
    if x["runtimeMinutes"] is not None:
        p.zadd("imdb:runtime", {x["tconst"]: x["runtimeMinutes"]})                       # koik
        if x["titleType"] == "movie": p.zadd("imdb:runtime:movie", {x["tconst"]: x["runtimeMinutes"]})   # ainult filmid
p.execute()
print("votmeid imdb:title:*:", len(list(r.scan_iter("imdb:title:*"))), "  sorted set imdb:runtime:movie:", r.zcard("imdb:runtime:movie"))
print("\nZREVRANGE imdb:runtime:movie 0 2 WITHSCORES")
for i, (tc, sc) in enumerate(r.zrevrange("imdb:runtime:movie", 0, 2, withscores=True), 1):
    h = r.hgetall(f"imdb:title:{tc}"); print(f"   {i}. {h['primaryTitle']} ({h['startYear']}) - {int(sc)} min")

# =================================================================== MONGODB
joon("3) MONGODB")
mc = pymongo.MongoClient("mongodb://127.0.0.1:27017"); col = mc["imdb"]["titles"]; col.delete_many({})
docs = [dict(x, _id=x["tconst"], genres=(x["genres"].split(",") if x["genres"] else [])) for x in ROWS]
col.insert_many(docs); col.create_index("runtimeMinutes")
print("dokumente kollektsioonis titles:", col.count_documents({}))
print("\ndb.titles.find({titleType:'movie'}).sort({runtimeMinutes:-1}).limit(3)")
for i, d in enumerate(col.find({"titleType": "movie", "runtimeMinutes": {"$ne": None}}).sort("runtimeMinutes", -1).limit(3), 1):
    print(f"   {i}. {d['primaryTitle']} ({d['startYear']}) - {d['runtimeMinutes']} min   zanrid: {d['genres']}")
print("zanrite arv (agregatsioon, top 3):", [(x['_id'], x['n']) for x in col.aggregate([{"$unwind": "$genres"}, {"$group": {"_id": "$genres", "n": {"$sum": 1}}}, {"$sort": {"n": -1}}, {"$limit": 3}])])

# ===================================================================== EXCEL
joon("4) EXCEL")
wb = Workbook(); ws = wb.active; ws.title = "imdbtitle"
ws.append(hdr + ["runtime (ainult movie)"])
for c in ws[1]: c.font, c.fill = Font(bold=True, color="FFFFFF"), PatternFill("solid", fgColor="0B5CFF")
for i, x in enumerate(ROWS, start=2):
    ws.append([x["tconst"], x["titleType"], x["primaryTitle"], x["originalTitle"], x["isAdult"], x["startYear"], x["endYear"], x["runtimeMinutes"], x["genres"]])
    ws[f"J{i}"] = f'=IF(B{i}="movie",H{i},"")'
n = len(ROWS) + 1
ws["L1"], ws["L2"] = "Koige pikem film (min)", f"=MAX(J2:J{n})"
ws["L4"], ws["L5"] = "Pealkiri", f"=INDEX(C2:C{n},MATCH(L2,J2:J{n},0))"
ws["L7"], ws["L8"] = "Aasta", f"=INDEX(F2:F{n},MATCH(L2,J2:J{n},0))"
ws["L10"] = "Jegor Onoprijuk, TA-24B"; ws["L10"].font = Font(bold=True)
for col in range(1, 13): ws.column_dimensions[get_column_letter(col)].width = 22
wb.save("imdb.xlsx"); print(f"salvestatud: imdb.xlsx ({len(ROWS)} rida; valemid MAX + INDEX/MATCH)")

joon("5) MILLINE ANDMEBAAS ON SELLE ULESANDE JAOKS PARIM?")
print("""Ulesanne on "loe tabulaarne fail sisse ja leia maksimum" - lihtne analuus uhe tabeli peal:

  MySQL    - PARIM. Fail on juba tabel kindlate veergudega; ORDER BY runtimeMinutes DESC
             LIMIT 1 on uks lihtne rida, indeks teeb selle kiireks ka miljonite ridade peal,
             ja SQL-iga saab kohe edasi kuskida (grupeerida, filtreerida, liita).
  MongoDB  - HEA. Sobib, kui tahame zanrid massiivina (genres: ['Drama','Short']) ja ridade
             struktuur voib muutuda; sort + limit toimib sama lihtsalt.
  Excel    - SOBIB TAIESTI SELLE SUURUSE JAOKS (531 rida): MAX + INDEX/MATCH annab vastuse
             ja tulemuse naeb kohe tabelis. Pole vaja serverit. Suurte failide puhul (miljonid
             read) jaab kitsaks.
  Redis    - POLE SELLE JAOKS. Sorted set imdb:runtime:movie annab maksimumi kiiresti
             (ZREVRANGE), aga igat teist paringut (nt "koik 1914. aasta komeediad") peab
             eraldi indeksina ette valmistama. Redis on moeldud votmete ja vahemalu jaoks.""")
