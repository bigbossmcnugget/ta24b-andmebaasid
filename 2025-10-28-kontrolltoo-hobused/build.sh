#!/bin/zsh
cd "$(dirname "$0")"
R=(-u root --socket=/tmp/maria.sock --default-character-set=utf8mb4)
J=(-u jegor_onoprijuk -pTA24B_parool --socket=/tmp/maria.sock --default-character-set=utf8mb4)
sed -e 's/utf8mb4_0900_ai_ci/utf8mb4_uca1400_ai_ci/g' Dump20251027.sql > /tmp/yhobu_load.sql
mariadb $R -e "DROP DATABASE IF EXISTS yhobu" 2>/dev/null
mariadb $R < /tmp/yhobu_load.sql 2>&1 | grep -v insecure
mariadb $R -e "GRANT ALL PRIVILEGES ON yhobu.* TO 'jegor_onoprijuk'@'localhost'; FLUSH PRIVILEGES" 2>/dev/null
{
echo "=============================================================="
echo " 2025-10-28  Kontrolltoo - hobuste andmebaas (yhobu)"
echo " Jegor Onoprijuk, ruhm TA-24B"
echo "=============================================================="
echo "kasutaja : $(whoami)"; echo "masin    : $(hostname -s)"; echo "kuupaev  : $(date '+%d.%m.%Y %H:%M:%S')"
echo "andmebaas: $(mariadb $R -N -B -e 'SELECT VERSION()' 2>/dev/null)  (mysql-kasutaja: jegor_onoprijuk)"
echo
echo "##### 0. opetaja dump laetud andmebaasi yhobu (enne minu muudatusi)"
mariadb $R -t yhobu -e "SELECT 'omanik' t, COUNT(*) n FROM omanik UNION ALL SELECT 'hobune',COUNT(*) FROM hobune UNION ALL SELECT 'tall',COUNT(*) FROM tall UNION ALL SELECT 'arst',COUNT(*) FROM arst UNION ALL SELECT 'inventar',COUNT(*) FROM inventar UNION ALL SELECT 'visiit',COUNT(*) FROM visiit" 2>&1 | grep -v insecure
echo
echo "##### 1. minu lahendus: yhobu_lahendus.sql"
mariadb $J < yhobu_lahendus.sql 2>&1 | grep -v insecure
echo "(valmis - vigu ei olnud)"
echo
echo "##### 2. testid ja noutud paringud"
mariadb $J -t < testid.sql 2>&1 | grep -v insecure
echo
echo "##### 3. reeglite kontroll (kolm viga on MEELEGA)"
for f in kontrollid kontrollid2 kontrollid3; do mariadb $J -t < $f.sql 2>&1 | grep -v insecure | grep -v "^+\|^|" ; done
} > valjund.txt 2>&1
