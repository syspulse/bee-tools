#!/bin/bash
# Prerequisites
#  1. seth installed https://github.com/dapphub/dapptools/tree/master/src/seth
#  2. ethrescan export API_KEY=<key>
#  3. keystore.key - file in geth format 
#  4. keystore.password - file with password for keystore.key (otherwise seth will be asking all the time)

[[ -z "$1" ]] && { echo "ETH address missing"; exit 1; }
[[ -e "keystore.key" ]] || { echo "keystore.key file is missing"; exit 1; }

ETH_FROM=${1}
ETH_PASSWORD=${2:-keystore.password}
ETH_RPC_URL=${3:-https://rpc.slock.it/goerli}

[[ -e "$ETH_PASSWORD" ]] || { echo "$ETH_PASSWORD file is missing"; exit 1; }

txs=`curl -s "https://api-goerli.etherscan.io/api?module=account&action=txlist&address=${ETH_FROM}&sort=asc&apikey=${API_KEY}" | jq -r '.result[] | select(.isError=="1") | [.hash]|@tsv'`

for tx in $txs; do
   echo "replaying: $tx"
   seth tx $tx | grep -E 'to|from|input' >/tmp/$tx.tmp
   to=`cat /tmp/$tx.tmp |grep to| awk '{print $2}'`
   data=`cat /tmp/$tx.tmp |grep input| awk '{print $2}'`
  
   echo "replay: $ETH_FROM -> $to ($data)"
   seth send --keystore=. --resend $to $data
done
