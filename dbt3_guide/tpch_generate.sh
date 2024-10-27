#!/usr/bin/env bash
set -euo pipefail
TMPDIR=$(mktemp --directory)
echo $TMPDIR
cp /tpch/queries/initialize.sql $TMPDIR/initialize.sql
pushd $TMPDIR
wget -q https://github.com/electrum/tpch-dbgen/archive/32f1c1b92d1664dba542e927d23d86ffa57aa253.zip -O tpch-dbgen.zip
unzip -q tpch-dbgen.zip
mv tpch-dbgen-32f1c1b92d1664dba542e927d23d86ffa57aa253/* .
rm tpch-dbgen.zip
make
set -x
./dbgen -f -s $3
pwd
ls -la .
chmod +r *.tbl
for table in ./*.tbl; do sed -i 's/|$//' "$table"; done
mv ./*.tbl /tpch/
