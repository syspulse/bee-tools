#!/bin/bash
# Prerequisites
#  1. seth installed https://github.com/dapphub/dapptools/tree/master/src/seth
#
# Usage examples: 
#    ./erc20-BZZ.sh  0x000000000000000000000000001 goerli http://localhost:8545
#    ./erc20-BZZ.sh  "0x000000000000000000000000001 0x000000000000000000000000002" goerli  http://localhost:8545
#    ./erc20-bZZ.sh  "`cat CHEQUEBOOKS | awk '{printf $1" "}'`" goerli http://localhost:8545

[[ -z "$1" ]] && { echo "Chequebooks Contract Addresses missing"; exit 1; }

CHEQUEBOOKS="${1}"
NET=${2:-goerli}
export ETH_RPC_URL=${3:-https://rpc.slock.it/goerli}

declare -A ERC20_CONTRACT_NET=( ["mainnet"]="0x19062190b1925b5b6689d7073fdfc8c2976ef8cb" ["goerli"]="0x2aC3c1d3e24b45c6C310534Bc2Dd84B5ed576335")

ERC20_CONTRACT=${ERC20_CONTRACT_NET[$NET]}

WEI=10000000000000000

>&2 echo "Net: $NET"
>&2 echo "ERC20 Contract Address: $ERC20_CONTRACT"
>&2 echo "CHEQUEBOOKS: $CHEQUEBOOKS"

for book in $CHEQUEBOOKS; do
   #>&2 echo "Address: $addr"
   addr=`seth call $book "issuer()(address)"`
   
   addr_balance_wei=`seth call $ERC20_CONTRACT "balanceOf(address)(int256)" $addr`
   addr_balance=`echo "scale=3; $addr_balance_wei / $WEI" | bc`

   payout_wei=`seth call $book "totalPaidOut()(uint256)"`
   payout=`echo "scale=3; $payout_wei / $WEI" | bc`

   balance_wei=`seth call $book "balance()(uint256)"`
   balance=`echo "scale=3; $balance_wei / $WEI" | bc`
   
   echo "chequebook: $book: totalPayout=$payout balance=$balance $addr=$addr_balance"
done
