#!/bin/zsh
# 2025-10-21 Kordamine - MySQL osa  -  Jegor Onoprijuk, TA-24B
cd "$(dirname "$0")"
W=/Users/jegorkerimov/Documents/Codex/2026-11-09/h/work
vm() { orb -m ta24b-lubuntu "$@"; }
{
echo "=============================================================="
echo " 2025-10-21  Kordamine: Virtualbox, Lubuntu, mysql, WebGoat  -  I MYSQL"
echo " Jegor Onoprijuk, ruhm TA-24B"
echo "=============================================================="
echo "kasutaja : $(whoami)"; echo "masin    : $(hostname -s)"; echo "kuupaev  : $(date '+%d.%m.%Y %H:%M:%S')"
echo "host     : $(sw_vers -productName) $(sw_vers -productVersion) ($(uname -m))"
echo
echo "##### 1. Virtuaalmasin (VirtualBoxi + Lubuntu asemel: OrbStack Ubuntu 24.04 masin)"
echo "\$ orbctl list"; orbctl list | grep ta24b
echo "\$ lsb_release -a  (masinas)"; vm lsb_release -ds 2>&1
echo "\$ uname -a  (masinas)"; vm uname -sr 2>&1
echo
echo "##### 2. apt update / upgrade / install mysql-server  (tehtud, vt allpool - mysql on paigaldatud)"
echo "\$ dpkg -l | grep mysql-server  (masinas)"; vm dpkg -l 2>/dev/null | grep -E "^ii\s+mysql-(server|client)" | awk '{printf "   %-22s %s\n", $2, $3}'
echo
echo "##### 3. Kontroll: kas mysql toodab?    # service mysql status"
vm service mysql status 2>&1 | sed -n '1,5p' | sed 's/^/   /'
echo "\$ ls /etc/mysql  (konf on kaustas /etc/mysql)"; vm ls /etc/mysql 2>&1 | sed 's/^/   /'
echo
echo "##### 4. Kasutaja:  # mysql  >create user mysql identified by 'mysql'; >grant all on *.* to mysql;"
vm sudo mysql -e "DROP USER IF EXISTS 'mysql'@'%'; CREATE USER 'mysql'@'%' IDENTIFIED WITH mysql_native_password BY 'mysql'; GRANT ALL ON *.* TO 'mysql'@'%' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>&1
vm sudo mysql -e "SELECT user, host, plugin FROM mysql.user WHERE user='mysql'; SHOW GRANTS FOR 'mysql'@'%'" 2>&1 | sed 's/^/   /'
echo
echo "##### 5. Host masinast ligipaas (NAT / port forwarding hostiports 3310 -> masina 3306)"
vm sudo sed -i 's/^bind-address.*/bind-address = 0.0.0.0/; s/^mysqlx-bind-address.*/mysqlx-bind-address = 0.0.0.0/' /etc/mysql/mysql.conf.d/mysqld.cnf
vm sudo service mysql restart 2>&1
echo "\$ grep bind-address /etc/mysql/mysql.conf.d/mysqld.cnf  (masinas)"; vm grep -E "^bind-address" /etc/mysql/mysql.conf.d/mysqld.cnf | sed 's/^/   /'
IP=$(orbctl list | awk '/ta24b-lubuntu/{print $NF}')
echo "   masina IP: $IP"
pkill -f "tcp_forward.py 3310" 2>/dev/null
nohup python3 tcp_forward.py 3310 $IP 3306 > /tmp/fwd3310.log 2>&1 &
sleep 1
echo "\$ lsof -iTCP:3310 -sTCP:LISTEN -nP    (host kuulab porti 3310)"
lsof -iTCP:3310 -sTCP:LISTEN -nP 2>/dev/null | awk 'NR>1{printf "   %-10s pid %-6s %s\n", $1, $2, $9}'
echo "\$ mysql -h 127.0.0.1 -P 3310 -u mysql -pmysql  (hostist, pordi 3310 kaudu masinas olevasse MySQL-i)"
mariadb -h 127.0.0.1 -P 3310 -u mysql -pmysql -t -e "SELECT CURRENT_USER() AS kasutaja, @@version AS versioon, @@version_comment AS server, @@hostname AS masin" 2>&1 | grep -v insecure
echo
echo "##### 6. World database (masinas olevasse MySQL-i), siis script.sql"
vm mysql -u mysql -pmysql -e "DROP DATABASE IF EXISTS world" 2>&1 | grep -v "insecure\|Using a password"
vm bash -c "mysql -u mysql -pmysql < $W/world/world_fixed.sql" 2>&1 | grep -v "insecure\|Using a password"
vm mysql -u mysql -pmysql -t -e "USE world; SELECT (SELECT COUNT(*) FROM country) riike, (SELECT COUNT(*) FROM city) linnu, (SELECT COUNT(*) FROM countrylanguage) keeli" 2>&1 | grep -v "Using a password"
echo
echo "##### 7. script.sql (opetaja fail) - lahendan hostist, pordi 3310 kaudu"
cp script.sql /tmp/k_script.sql
mariadb -h 127.0.0.1 -P 3310 -u mysql -pmysql --default-character-set=utf8mb4 -t < /tmp/k_script.sql 2>&1 | grep -v insecure > /tmp/k_script.out
echo "   tulemusi (ridu valjundis): $(wc -l < /tmp/k_script.out)"
echo "\$ select code, name, headofstate from country where code='EST'  (parast update-i Alar Karis)"
mariadb -h 127.0.0.1 -P 3310 -u mysql -pmysql -t --default-character-set=utf8mb4 world -e "SELECT code, name, headofstate FROM country WHERE code IN ('EST','ALI')" 2>&1 | grep -v insecure
echo "\$ lisatud koloonia:"
mariadb -h 127.0.0.1 -P 3310 -u mysql -pmysql -t --default-character-set=utf8mb4 world -e "SELECT co.name AS riik, co.code, ci.name AS linn, ci.population FROM city ci JOIN country co ON ci.countrycode=co.code WHERE co.code='ALI'" 2>&1 | grep -v insecure
echo "\$ mitu riiki on mingil kontinendil ja mitu inimest seal elab"
mariadb -h 127.0.0.1 -P 3310 -u mysql -pmysql -t world -e "SELECT continent, COUNT(*) riike, SUM(population) inimesi FROM country GROUP BY continent ORDER BY 3 DESC" 2>&1 | grep -v insecure
} > valjund_mysql.txt 2>&1
