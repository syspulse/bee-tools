#!/bin/bash
# Based on Avergage Price over last 10 blocks

HISTORY=${1:-10}
ETH_RPC_URL=${2:-https://rpc.slock.it/goerli}

./tx-gas-stat.sh $HISTORY $ETH_RPC_URL 2>/dev/null | tail -1| awk '{print $6}'
