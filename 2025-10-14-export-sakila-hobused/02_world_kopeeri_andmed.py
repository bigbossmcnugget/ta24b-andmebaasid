# B1: kopeerib world andmed MySQL/MariaDB-st SQLite faili world.db   Jegor Onoprijuk, TA-24B
import sqlite3, pymysql, os
if os.path.exists('world.db'): os.remove('world.db')
lt = sqlite3.connect('world.db')
lt.executescript(open('01_world_schema_sqlite.sql', encoding='utf-8').read())
my = pymysql.connect(unix_socket='/tmp/maria.sock', user='mysql', password='mysql', database='world', charset='utf8mb4')
cur = my.cursor()
for t in ('country', 'city', 'countrylanguage'):
    cur.execute(f'SELECT * FROM {t}')
    rows = [tuple(float(v) if hasattr(v, 'as_tuple') else v for v in r) for r in cur.fetchall()]
    lt.executemany(f'INSERT INTO {t} VALUES ({",".join("?" * len(rows[0]))})', rows)
    print(t, len(rows), 'rida kopeeritud')
lt.commit()
