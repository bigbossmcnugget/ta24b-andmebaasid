#!/bin/zsh
cd "$(dirname "$0")"
{
cat valjund_mysql.txt
echo
echo "##### II WEBGOAT (OWASP) - SQL injection"
echo "\$ docker run --name webgoat -it -p 127.0.0.1:8080:8080 -p 127.0.0.1:9090:9090 webgoat/webgoat"
echo "   (jooksutatud -d ehk taustal; docker on OrbStack-is, mitte masina sees - vt README)"
echo "\$ docker ps --filter name=webgoat"
docker ps --filter name=webgoat --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' | sed 's/^/   /'
echo "\$ lsof -iTCP -sTCP:LISTEN -nP | grep -E ':8080|:9090'"
lsof -iTCP -sTCP:LISTEN -nP 2>/dev/null | grep -E ":8080|:9090" | awk '{printf "   %-12s pid %-6s %s\n", $1, $2, $9}'
echo "\$ curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/WebGoat/login   ->  $(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:8080/WebGoat/login)"
echo
echo "\$ python3 webgoat_sql.py     (registreerimine + SQL injection ulesanded)"
cat /tmp/wg_run.txt
echo
echo "=============================================================="
echo "Too tegi: Jegor Onoprijuk (jegorkerimov@$(hostname -s)), TA-24B"
echo "=============================================================="
} > valjund.txt
