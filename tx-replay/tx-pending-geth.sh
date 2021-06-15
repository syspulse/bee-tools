#!/bin/bash
# Prerequisites
#  1. seth installed https://github.com/dapphub/dapptools/tree/master/src/seth
#  2. Same node as geth (because of IPC connection)

[[ -z "$1" ]] && { echo "Address missing"; exit 1; }

ETH_FROM=${1:-$ETH_FROM}

>&2 echo "Address: $ETH_FROM"
>&2 echo "GETH_HOME: $GETH_HOME"
>&2 echo "GETH_DATA: $GETH_DATA"

if [ "$GETH_HOME" == "" ]; then
   GETH="geth "
else
   if [ "$GETH_DATA" != "" ]; then
      DATA="--datadir $GETH_DATA"
   fi
   GETH="$GETH_HOME/geth $DATA"
fi

TXS=`$GETH --exec "txpool.content.pending[web3.toChecksumAddress(\"$ETH_FROM\")]" attach |grep hash |awk '{print substr($2,2,length($2)-3)}'`

for tx in $TXS; do
   echo "$tx"
done