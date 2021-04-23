#!/bin/bash
ETH_ADDRESS="${1:-$ETH_ADDRESS}"
CONTRACT_ADDRESS="${2:-$CONTRACT_ADDRESS}"

echo "Address: $ETH_ADDRESS"
echo "Chequebook: $CONTRACT_ADDRESS"

./cashout-db.sh $ETH_ADDRESS $CONTRACT_ADDRESS

in=`cat $CONTRACT_ADDRESS-in.tsv | ./cashout-sum.sh 2>/dev/null`
out=`cat $CONTRACT_ADDRESS-out.tsv | ./cashout-sum.sh 2>/dev/null`

echo "Total (in):  $in gBZZ"
echo "Total (out): $out gBZZ"

