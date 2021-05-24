#!/bin/bash
ADDR=${1:-0x0000000000000000000000000000000000000001}
ABI_SIGNATURE="0x0d5f2659"

TXS_FILE=txs-${ADDR}.json
GAS_FILE=gas-${ADDR}.log

curl "https://api-goerli.etherscan.io/api?module=account&action=txlist&address=${ADDR}&apikey=$API_KEY" >$TXS_FILE

cat $TXS_FILE |jq -r '.result[] | .gasUsed,.gas,.isError,.from,.input' | paste - - - - -|grep "$ABI_SIGNATURE" | grep $ADDR >$GAS_FILE

max=`cat $GAS_FILE | awk 'NR==1||$1>x{x=$1}END{print x}'`
min=`cat $GAS_FILE | awk 'NR==1||$1<x{x=$1}END{print x}'`

echo "$ADDR $min $max"
