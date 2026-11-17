#!/bin/zsh
# 2026-01-15  wsl + mysql + World database  -  Jegor Onoprijuk, TA-24B
cd "$(dirname "$0")"
W=/Users/jegorkerimov/Documents/Codex/2026-11-09/h/work
R=(-u root --socket=/tmp/maria.sock --default-character-set=utf8mb4)
M=(-u mysql -pmysql --socket=/tmp/maria.sock --default-character-set=utf8mb4)
{
echo "=============================================================="
echo " 2026-01-15  MySQL + World database"
echo " Jegor Onoprijuk, ruhm TA-24B"
echo "=============================================================="
echo "kasutaja : $(whoami)"; echo "masin    : $(hostname -s)"; echo "kuupaev  : $(date '+%d.%m.%Y %H:%M:%S')"
echo "systeem  : $(sw_vers -productName) $(sw_vers -productVersion) ($(uname -m))   <- WSL/Ubuntu asemel natiivne macOS"
echo
echo "\$ mariadbd --version"; mariadbd --version
echo "\$ ps aux | grep mariadbd"; ps aux | grep "[m]ariadbd" | grep -v "zsh -c" | awk '{print "   pid "$2"  "$11" "$12" "$13" "$14}'
echo
echo "\$ CREATE USER 'mysql'@'localhost' IDENTIFIED BY 'mysql'; GRANT ALL ON *.* TO 'mysql'@'localhost' WITH GRANT OPTION;"
mariadb $R -e "CREATE USER IF NOT EXISTS 'mysql'@'localhost' IDENTIFIED BY 'mysql'; GRANT ALL PRIVILEGES ON *.* TO 'mysql'@'localhost' WITH GRANT OPTION; FLUSH PRIVILEGES;" 2>&1 | grep -v insecure
mariadb $M -t -e "SELECT CURRENT_USER() AS sisse_logitud_kasutajaga, VERSION() AS versioon" 2>&1 | grep -v insecure
echo
echo "\$ mariadb -u mysql -pmysql < world.sql        (World database)"
mariadb $M -e "DROP DATABASE IF EXISTS world" 2>&1 | grep -v insecure
sed -e 's/utf8mb4_0900_ai_ci/utf8mb4_uca1400_ai_ci/g' $W/world/world_fixed.sql | mariadb $M 2>&1 | grep -v insecure
mariadb $M -t world -e "SHOW TABLES; SELECT (SELECT COUNT(*) FROM country) AS riike, (SELECT COUNT(*) FROM city) AS linnu, (SELECT COUNT(*) FROM countrylanguage) AS keeli" 2>&1 | grep -v insecure
echo
echo "##### ULESANNE: mitmes riigis on selles andmebaasis olevate andmete pohjal riigipea Elisabeth II?"
echo "\$ SELECT COUNT(*) AS riike FROM country WHERE HeadOfState = 'Elisabeth II';"
mariadb $M -t world -e "SELECT COUNT(*) AS riike FROM country WHERE HeadOfState = 'Elisabeth II'" 2>&1 | grep -v insecure
echo
echo "\$ SELECT Name, Continent FROM country WHERE HeadOfState = 'Elisabeth II' ORDER BY Continent, Name;   (kontrolliks, kes need riigid on)"
mariadb $M -t world -e "SELECT Name, Continent, GovernmentForm FROM country WHERE HeadOfState = 'Elisabeth II' ORDER BY Continent, Name" 2>&1 | grep -v insecure
echo
echo "\$ SELECT HeadOfState, COUNT(*) AS riike FROM country WHERE HeadOfState LIKE 'Elisabeth%' GROUP BY HeadOfState;   (kirjapildi kontroll)"
mariadb $M -t world -e "SELECT HeadOfState, COUNT(*) AS riike FROM country WHERE HeadOfState LIKE '%Elisabeth%' GROUP BY HeadOfState" 2>&1 | grep -v insecure
echo
echo "=============================================================="
echo "Too tegi: Jegor Onoprijuk (jegorkerimov@$(hostname -s)), TA-24B"
echo "=============================================================="
} > valjund.txt 2>&1
