#!/bin/bash
# Prerequisites
#  1. seth installed https://github.com/dapphub/dapptools/tree/master/src/seth
#  2. *.key - files with keystores for "from" in geth format 
#  3. ETH_PASSWORD - variable set to keystore password
# Use tx-pending-geth.sh to get a list of pending (stuck) transactions

[[ -z "$1" ]] && { echo "Transaction hashes missing"; exit 1; }

TXS=${1}
GAS_PRICE=${2:-25}
export ETH_RPC_URL=${3:-https://rpc.slock.it/goerli}
export ETH_KEYSTORE=${4:-$ETH_KEYSTORE}
export ETH_PASSWORD=${5:-$ETH_PASSWORD}
export ETH_GAS=${5:-300000}

>&2 echo "Address: $ETH_FROM"
>&2 echo "ETH_RPC_URL: $ETH_RPC_URL"
>&2 echo "GAS_PRICE: $GAS_PRICE"
>&2 echo "ETH_GAS: $ETH_GAS"
>&2 echo "ETH_KEYSTORE: $ETH_KEYSTORE"

for tx in $TXS; do
   echo "replaying: $tx"
   
   TX_DATA_TMP=/tmp/$tx.data.tmp

   curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getTransactionByHash\",\"params\":[\"${tx}\"],\"id\":1}" -H "Content-Type: application/json" $ETH_RPC_URL | jq ".result.to,.result.from,.result.nonce,.result.input" >$TX_DATA_TMP
   
   to=`head -1 $TX_DATA_TMP`
   from=`head -2 $TX_DATA_TMP| tail -1`
   nonce=`head -3 $TX_DATA_TMP| tail -1`
   data=`head -4 $TX_DATA_TMP| tail -1`

   to="${to:1:${#to}-2}"
   from="${from:1:${#from}-2}"
   nonce="${nonce:1:${#nonce}-2}"
   data="${data:1:${#data}-2}"
  
   echo "replay: $from -> $to: nonce=$nonce: gas=${GAS_PRICE}: data=$data"
   
   ETH_FROM=${from} seth send --keystore=${ETH_KEYSTORE} --nonce=$nonce --gas-price=$(seth --to-wei $GAS_PRICE gwei) --resend $to $data

   rm $TX_DATA_TMP
done
