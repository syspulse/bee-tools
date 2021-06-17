#!/bin/bash
# Shows gas statistics over the last N blocks
# Prerequisites
#  2. curl installed
#  3. seq installed
#  4. ministat installed

HISTORY=${1:-5}
export ETH_RPC_URL=${2:-https://rpc.slock.it/goerli}
TMP_TOTAL_GAS="/tmp/tx-gas-stat-gas.tmp"

>&2 echo "History: $HISTORY blocks"
>&2 echo "ETH_RPC_URL: $ETH_RPC_URL"

last=`curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_blockNumber\",\"id\":1}" -H "Content-Type: application/json" $ETH_RPC_URL | jq .result`
last="${last:1:${#last}-2}"

>&2 echo "Last block: $last"
let start=last-HISTORY+1

>&2 echo "First block: $start"

rm -f $TMP_TOTAL_GAS

for b in `seq $start 1 $last`; do
   block=0x`printf "%x" $b`
   >&2 echo "block: $b ($block)"

   txs=`curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getBlockByNumber\",\"params\":[\"${block}\",false],\"id\":1}" -H "Content-Type: application/json" $ETH_RPC_URL | jq -r '.result.transactions[]' | paste -sd" " -`
   for tx in $txs; do 
      
      TX_DATA_TMP=/tmp/$b.tmp

      curl -s -X POST --data "{\"jsonrpc\":\"2.0\",\"method\":\"eth_getTransactionByHash\",\"params\":[\"${tx}\"],\"id\":1}" -H "Content-Type: application/json" $ETH_RPC_URL | jq  -r ".result.gas,.result.gasPrice" >$TX_DATA_TMP
      
      gas=`head -1 $TX_DATA_TMP`
      gas_price=`head -2 $TX_DATA_TMP| tail -1`

      gas=`printf "%d" $gas`
      gas_price=`printf "%d" $gas_price`
      gwei_price=`echo "$gas_price / 1000000000" | bc`
      
      >&2 echo "Tx: $tx: gas=${gas}: gas_price=$gwei_price"
      
      rm $TX_DATA_TMP

      >&2 echo "$gas $gwei_price" >>$TMP_TOTAL_GAS
   done
done

echo "Gas:"
cat $TMP_TOTAL_GAS | ministat -n -C 1 |grep -v stdin
echo "Gas Price"
cat $TMP_TOTAL_GAS | ministat -n -C 2 |grep -v stdin