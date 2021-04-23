#!/bin/bash
ETH_ADDRESS="${1:-$ETH_ADDRESS}"
CONTRACT_ADDRESS="${2:-$CONTRACT_ADDRESS}"

SQL_OUT="cashout-tx-out.sql"
SQL_IN="cashout-tx-in.sql"
TX_OUT="$CONTRACT_ADDRESS-out.tsv"
TX_IN="$CONTRACT_ADDRESS-in.tsv"

DB_USER=${3:-$DB_USER}
DB_PASS=${4:-$DB_PASS}
DB_DATABASE="ethereum_ethereum_goerli"
DB_HOST="sql.anyblock.net"

SQL="/tmp/cashout.sql"

cat ${SQL_OUT} | sed "s/CONTRACT_ADDRESS/${CONTRACT_ADDRESS}/g" >$SQL
echo "Loading tx (out): $CONTRACT_ADDRESS -> ..."
cat $SQL
PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=5432 --username=$DB_USER --dbname=$DB_DATABASE -t -f $SQL >$TX_OUT
echo -e "\ntx file: $TX_OUT"

cat ${SQL_IN} | sed "s/ETH_ADDRESS/${ETH_ADDRESS}/g" >$SQL
echo "Loading tx (in): $CONTRACT_ADDRESS <- ..."
cat $SQL
PGPASSWORD=$DB_PASS psql --host=$DB_HOST --port=5432 --username=$DB_USER --dbname=$DB_DATABASE -t -f $SQL >$TX_IN
echo -e "\ntx file: $TX_IN"
