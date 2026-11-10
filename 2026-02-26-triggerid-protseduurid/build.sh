#!/bin/zsh
# Kogu too uhe kaivitusega: baas -> testid -> log -> dump
# Jegor Onoprijuk, TA-24B
cd "$(dirname "$0")"
U=(-u jegor_onoprijuk -pTA24B_parool --socket=/tmp/maria.sock)
R=(-u root --socket=/tmp/maria.sock)
LOG=valjund.txt
{
echo "=============================================================="
echo " 2026-02-26  Triggers, procedures  -  TA24Bbank"
echo " Jegor Onoprijuk, ruhm TA-24B"
echo "=============================================================="
echo "kasutaja : $(whoami)"
echo "masin    : $(hostname -s)"
echo "kuupaev  : $(date '+%d.%m.%Y %H:%M:%S')"
echo "andmebaas: $(mariadb $R -N -B -e 'SELECT VERSION()' 2>/dev/null)"
echo "mysql-kasutaja (minu nimeline): jegor_onoprijuk"
echo
echo "##### 1. andmebaas, triggerid ja protseduurid: 01_triggerid_protseduurid.sql"
mariadb "${U[@]}" < 01_triggerid_protseduurid.sql 2>&1 | grep -v insecure
echo "(valmis)"
echo
echo "##### 2. testid: 03_testid.sql"
mariadb "${U[@]}" -t < 03_testid.sql 2>&1 | grep -v insecure
echo
echo "##### 3. viga-test: sama e-post teist korda -> ROLLBACK"
mariadb "${U[@]}" -t < 04_viga_test.sql 2>&1 | grep -v insecure
mariadb "${U[@]}" -t < 05_pohjalikum.sql 2>&1 | grep -v insecure
} > $LOG 2>&1
mariadb-dump $R --databases TA24Bbank_trig --routines --triggers --skip-comments 2>/dev/null \
  | sed -E 's/DEFINER=`[^`]*`@`[^`]*`//g' > 02_TA24Bbank_trig_dump_Jegor_Onoprijuk.sql
python3 - <<'PY'
s=open('01_triggerid_protseduurid.sql',encoding='utf-8').read()
proc=s[s.index('-- ----------------------------------------------------------- protseduurid'):]
d=open('02_TA24Bbank_trig_dump_Jegor_Onoprijuk.sql',encoding='utf-8').read().rstrip()
d+="\n\n-- Protseduurid (mariadb-dump 13 jatab need --routines korral vahele, seega\n-- lisasin kasitsi - samad, mis failis 01_triggerid_protseduurid.sql)\nUSE `TA24Bbank_trig`;\n"+proc
open('02_TA24Bbank_trig_dump_Jegor_Onoprijuk.sql','w',encoding='utf-8').write(d)
PY
{
echo
echo "##### 4. dumpi kontroll: kustutan baasi ja laen dumbist tagasi"
echo "\$ mariadb -e 'DROP DATABASE TA24Bbank_trig'"
echo "\$ mariadb < 02_TA24Bbank_trig_dump_Jegor_Onoprijuk.sql"
mariadb $R -e "DROP DATABASE TA24Bbank_trig" 2>/dev/null
mariadb $R < 02_TA24Bbank_trig_dump_Jegor_Onoprijuk.sql 2>&1 | grep -v insecure
mariadb $R -e "GRANT ALL PRIVILEGES ON TA24Bbank_trig.* TO 'jegor_onoprijuk'@'localhost'" 2>/dev/null
mariadb $R -t TA24Bbank_trig -e "
SELECT (SELECT COUNT(*) FROM customer) AS kliente, (SELECT COUNT(*) FROM account) AS kontosid,
       (SELECT COUNT(*) FROM audit) AS audit_ridu;
SELECT * FROM audit_kokkuvote;
INSERT INTO customer (idcode,firstname,lastname,customertype) VALUES (1,'Kontroll','Taastatud','BASIC');
SELECT COUNT(*) AS audit_ridu_parast_uut_insert_i FROM audit;
DELETE FROM customer WHERE idcode=1;
DELETE FROM audit WHERE tableid='1';" 2>&1 | grep -v insecure
echo "-> triggerid, vaade ja protseduurid toodavad ka taastatud baasis."
echo
echo "=============================================================="
echo "Too tegi: Jegor Onoprijuk (jegorkerimov@$(hostname -s)), TA-24B"
echo "=============================================================="
} >> $LOG 2>&1
