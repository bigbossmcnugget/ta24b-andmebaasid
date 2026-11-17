#!/bin/zsh
# 2026-01-22  Install wsl, mysql, mongodb, redis  -  Jegor Onoprijuk, TA-24B
cd "$(dirname "$0")"
W=/Users/jegorkerimov/Documents/Codex/2026-11-09/h/work
RC=$W/redis-dl/redis-stable/src/redis-cli
RS=$W/redis-dl/redis-stable/src/redis-server
PY=$W/ylesanne1209/venv/bin/python
R=(-u root --socket=/tmp/maria.sock --default-character-set=utf8mb4)
{
echo "=============================================================="
echo " 2026-01-22  Install: mysql, mongodb, redis"
echo " Jegor Onoprijuk, ruhm TA-24B"
echo "=============================================================="
echo "kasutaja : $(whoami)"; echo "masin    : $(hostname -s)"; echo "kuupaev  : $(date '+%d.%m.%Y %H:%M:%S')"
echo "systeem  : $(sw_vers -productName) $(sw_vers -productVersion) ($(uname -m))   <- WSL/Ubuntu asemel natiivne macOS"
echo
echo "##### I MYSQL (MariaDB 13 - MySQL-iga uhilduv server)"
echo "\$ mariadbd --version"; mariadbd --version
echo "\$ ps aux | grep mariadbd"; ps aux | grep "[m]ariadbd" | grep -v "zsh -c" | awk '{print "   pid "$2"  "$11" "$12" "$13" "$14}'
echo
echo "\$ CREATE USER 'mysql'@'localhost' IDENTIFIED BY 'mysql'; GRANT ALL ON *.* TO 'mysql'@'localhost' WITH GRANT OPTION;"
mariadb $R -e "CREATE USER IF NOT EXISTS 'mysql'@'localhost' IDENTIFIED BY 'mysql'; CREATE USER IF NOT EXISTS 'mysql'@'127.0.0.1' IDENTIFIED BY 'mysql'; GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'localhost' WITH GRANT OPTION; GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'127.0.0.1' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>&1 | grep -v insecure
echo "\$ SHOW GRANTS FOR 'mysql'@'localhost';"
mariadb $R -N -e "SHOW GRANTS FOR 'mysql'@'localhost'" 2>&1 | grep -v insecure | sed 's/IDENTIFIED BY PASSWORD .*//'
echo
echo "\$ mariadb -h 127.0.0.1 -P 3306 -u mysql -pmysql -e 'SELECT CURRENT_USER()'"
mariadb -h 127.0.0.1 -P 3306 -u mysql -pmysql -t -e "SELECT CURRENT_USER() AS kasutaja, @@port AS port" 2>&1 | grep -v insecure
echo
echo "\$ lisan World database:  mariadb -u mysql -pmysql < world_fixed.sql"
mariadb -u mysql -pmysql --socket=/tmp/maria.sock -e "DROP DATABASE IF EXISTS world" 2>&1 | grep -v insecure
sed -e 's/utf8mb4_0900_ai_ci/utf8mb4_uca1400_ai_ci/g' $W/world/world_fixed.sql | mariadb -u mysql -pmysql --socket=/tmp/maria.sock --default-character-set=utf8mb4 2>&1 | grep -v insecure
mariadb -u mysql -pmysql --socket=/tmp/maria.sock -t world -e "SHOW TABLES; SELECT (SELECT COUNT(*) FROM country) AS riike, (SELECT COUNT(*) FROM city) AS linnu, (SELECT COUNT(*) FROM countrylanguage) AS keeli; SELECT Name, Population FROM country WHERE Code='EST';" 2>&1 | grep -v insecure
echo
echo "##### II MONGODB"
echo "\$ mongod --version"; $W/mongo-dl/mongodb-macos-aarch64--8.0.17/bin/mongod --version | head -1
echo "\$ ps aux | grep mongod"; ps aux | grep "[m]ongod --dbpath" | awk '{print "   pid "$2"  mongod "$13" "$14" "$15" "$16}'
echo "\$ lisan 'testandmebaas' (pymongo; mongosh ja Compass pole arvutis, Compass on GUI-klient)"
$PY - <<'PYEOF'
import pymongo, datetime
c = pymongo.MongoClient("mongodb://127.0.0.1:27017"); db = c["testandmebaas"]
db.drop_collection("tudengid")
db.tudengid.insert_many([
  {"eesnimi": "Jegor", "perekonnanimi": "Onoprijuk", "ruhm": "TA-24B", "aine": "Andmebaasid", "lisatud": datetime.datetime.now()},
  {"eesnimi": "Mari", "perekonnanimi": "Tamm", "ruhm": "TA-24B", "aine": "Andmebaasid", "lisatud": datetime.datetime.now()},
  {"eesnimi": "Jaan", "perekonnanimi": "Kask", "ruhm": "TA-24B", "aine": "Operatsioonisusteemid", "lisatud": datetime.datetime.now()}])
print("> show dbs        :", sorted(x for x in c.list_database_names() if x not in ("admin", "config", "local")))
print("> use testandmebaas; show collections :", db.list_collection_names())
print("> db.tudengid.countDocuments({})      :", db.tudengid.count_documents({}))
print("> db.tudengid.find({ruhm:'TA-24B', aine:'Andmebaasid'}):")
for d in db.tudengid.find({"ruhm": "TA-24B", "aine": "Andmebaasid"}, {"_id": 0, "lisatud": 0}): print("    ", d)
db.tudengid.update_one({"eesnimi": "Mari"}, {"$set": {"aine": "Operatsioonisusteemid"}})
print("> updateOne Mari -> aine muudetud     :", db.tudengid.find_one({"eesnimi": "Mari"}, {"_id": 0, "eesnimi": 1, "aine": 1}))
PYEOF
echo
echo "##### III REDIS"
echo "\$ redis-server --version"; $RS --version
echo "\$ redis-cli ping  ->  $($RC ping)"
echo "\$ lsof -iTCP -sTCP:LISTEN -nP | grep -E 'redis|mongod|mariadbd'     (Linuxis: sudo netstat -tunlp | grep redis)"
lsof -iTCP -sTCP:LISTEN -nP 2>/dev/null | grep -E "redis|mongod|mariadbd" | awk '{printf "   %-12s pid %-6s %s\n", $1, $2, $9}'
echo
echo "\$ redis-cli set tervitus 'Jegor Onoprijuk, TA-24B'  ->  $($RC set tervitus 'Jegor Onoprijuk, TA-24B')"
echo "\$ redis-cli get tervitus  ->  $($RC get tervitus)"
echo "\$ redis-cli hset opilane:1 nimi 'Jegor Onoprijuk' ruhm TA-24B  ->  $($RC hset opilane:1 nimi 'Jegor Onoprijuk' ruhm TA-24B)"
echo "\$ redis-cli hgetall opilane:1  ->  $($RC hgetall opilane:1 | tr '\n' ' ')"
echo
echo "--- Redis stop / start / restart (Linuxis: systemctl stop|start redis) ---"
echo "\$ redis-cli shutdown nosave"; $RC shutdown nosave 2>&1; sleep 1
echo "   ping parast stopi:  $($RC ping 2>&1 | head -1)"
echo "   port 6379 kuulab:   $(lsof -iTCP:6379 -sTCP:LISTEN -nP 2>/dev/null | wc -l | tr -d ' ') protsessi"
echo "\$ redis-server --port 6379 --bind 127.0.0.1 &"
(nohup $RS --port 6379 --bind 127.0.0.1 --save "" --dir $W/dbdata > /tmp/redis.log 2>&1 &) ; sleep 2
echo "   ping parast starti: $($RC ping)"
echo "   port 6379 kuulab:   $(lsof -iTCP:6379 -sTCP:LISTEN -nP 2>/dev/null | grep -c LISTEN) protsessi"
echo "   (andmed on mallu: 'get tervitus' parast restarti -> $($RC get tervitus | sed 's/^$/(nil)/'))  <- Redis on malu-andmebaas"
echo
echo "=============================================================="
echo "Too tegi: Jegor Onoprijuk (jegorkerimov@$(hostname -s)), TA-24B"
echo "=============================================================="
} > valjund.txt 2>&1
