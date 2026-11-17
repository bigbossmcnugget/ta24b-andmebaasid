#!/bin/zsh
# 2026-02-05  Kontrollige oma tookeskkonda  -  Jegor Onoprijuk, TA-24B
cd "$(dirname "$0")"
W=/Users/jegorkerimov/Documents/Codex/2026-11-09/h/work
S=$W/sakila_dl/x/sakila-db
R=(-u root --socket=/tmp/maria3307.sock --default-character-set=utf8mb4)
M=(-h 127.0.0.1 -P 3307 -u mysql -pmysql --default-character-set=utf8mb4)
{
echo "=============================================================="
echo " 2026-02-05  Kontrollige oma tookeskkonda"
echo " Jegor Onoprijuk, ruhm TA-24B"
echo "=============================================================="
echo "kasutaja : $(whoami)"; echo "masin    : $(hostname -s)"; echo "kuupaev  : $(date '+%d.%m.%Y %H:%M:%S')"
echo "systeem  : $(sw_vers -productName) $(sw_vers -productVersion) ($(uname -m))   <- WSL/Ubuntu asemel natiivne macOS"
echo
echo "##### 1. Kas mysql toodab?   (Linuxis: sudo systemctl status mysql)"
echo "\$ ps aux | grep mariadbd | grep 3307"
ps aux | grep "[m]ariadbd" | grep 3307 | grep -v "zsh -c" | awk '{print "   pid "$2"  "$11" "$12}'
echo
echo "##### 2. Kas mysql kasutab porti 3307?   (Linuxis: sudo netstat -tlpn | grep mysql)"
echo "\$ lsof -iTCP -sTCP:LISTEN -nP | grep mariadbd"
lsof -iTCP -sTCP:LISTEN -nP 2>/dev/null | grep mariadbd | awk '{printf "   %-10s pid %-6s %s\n", $1, $2, $9}'
echo
echo "##### 3. Seadistusfail   (Linuxis: /etc/mysql/mysql.conf.d/ - port 3307, bind-address)"
echo "\$ cat my3307.cnf"; grep -v "^$" my3307.cnf | sed "s#$W#<projekt>#"
echo "\$ SHOW VARIABLES LIKE 'port'; SHOW VARIABLES LIKE 'bind_address';"
mariadb $R -t -e "SHOW VARIABLES WHERE Variable_name IN ('port','bind_address','socket')" 2>&1 | grep -v insecure | sed "s#$W#<projekt>#"
echo
echo "##### 4. Teine mysql (port 3306) on samal ajal olemas, see EI hakka vastu   (Windowsis: Services -> mysql manual + stopped)"
echo "\$ lsof -iTCP -sTCP:LISTEN -nP | grep -E ':3306|:3307'"
lsof -iTCP -sTCP:LISTEN -nP 2>/dev/null | grep -E ":3306|:3307" | awk '{printf "   %-10s pid %-6s %s\n", $1, $2, $9}'
echo
echo "##### 5. Workbenchi jaoks kasutaja 'mysql' koigi oigustega"
mariadb $R -e "CREATE USER IF NOT EXISTS 'mysql'@'localhost' IDENTIFIED BY 'mysql'; CREATE USER IF NOT EXISTS 'mysql'@'127.0.0.1' IDENTIFIED BY 'mysql'; GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'localhost' WITH GRANT OPTION; GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'127.0.0.1' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>&1 | grep -v insecure
echo "\$ mariadb -h 127.0.0.1 -P 3307 -u mysql -pmysql   (TCP-uhendus, nagu Workbench teeb)"
mariadb $M -t -e "SELECT CURRENT_USER() AS kasutaja, @@port AS port, VERSION() AS versioon; SHOW GRANTS" 2>&1 | grep -v insecure | sed 's/IDENTIFIED BY PASSWORD .*//'
echo
echo "##### 6. Sakila andmebaas   (curl -> sakila-db.tar.gz -> schema + data)"
echo "\$ ls sakila-db/";  ls -1 $S | sed 's/^/   /'
echo "\$ mariadb -u mysql -pmysql < sakila-schema.sql  &&  mariadb -u mysql -pmysql < sakila-data.sql"
mariadb $M -e "DROP DATABASE IF EXISTS sakila" 2>&1 | grep -v insecure
mariadb $M < $S/sakila-schema.sql 2>&1 | grep -v insecure
mariadb $M < $S/sakila-data.sql 2>&1 | grep -v insecure
mariadb $M -t sakila -e "SELECT 'actor' tabel, COUNT(*) ridu FROM actor UNION ALL SELECT 'film', COUNT(*) FROM film UNION ALL SELECT 'customer', COUNT(*) FROM customer UNION ALL SELECT 'rental', COUNT(*) FROM rental UNION ALL SELECT 'payment', COUNT(*) FROM payment UNION ALL SELECT 'inventory', COUNT(*) FROM inventory" 2>&1 | grep -v insecure
echo
echo "##### 7. Kontrollparingud Sakilal (uhendus pordi 3307 kaudu)"
echo "\$ 5 koige rohkem renditud filmi"
mariadb $M -t sakila -e "SELECT f.title AS film, COUNT(r.rental_id) AS rentale FROM film f JOIN inventory i ON i.film_id=f.film_id JOIN rental r ON r.inventory_id=i.inventory_id GROUP BY f.film_id, f.title ORDER BY rentale DESC, film LIMIT 5" 2>&1 | grep -v insecure
echo "\$ 5 koige rohkem maksnud klienti"
mariadb $M -t sakila -e "SELECT CONCAT(c.first_name,' ',c.last_name) AS klient, ROUND(SUM(p.amount),2) AS makstud FROM customer c JOIN payment p ON p.customer_id=c.customer_id GROUP BY c.customer_id ORDER BY makstud DESC LIMIT 5" 2>&1 | grep -v insecure
echo
echo "=============================================================="
echo "Too tegi: Jegor Onoprijuk (jegorkerimov@$(hostname -s)), TA-24B"
echo "=============================================================="
} > valjund.txt 2>&1
