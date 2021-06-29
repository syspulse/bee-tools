#!/bin/bash
# All Credits to: https://gist.github.com/ralph-pichler/3b5ccd7a5c5cd0500e6428752b37e975#file-cashout-sh
# Use BZZ precision everywhere

BZZ_PRECISION=10000000000000000

CMD=${1:-cheques}
NODE=${2:-0}
THRESHOLD=${3:-0.001}
HOST=${4:-localhost}
GAS_PRICE_GWEI=${5:-10}

DEBUG_API="http://${HOST}:183${NODE}"

GAS_PRICE=`echo "scale=1; $GAS_PRICE_GWEI*1000000000" | bc | xargs printf "%.0f"`
MIN_AMOUNT=`echo "scale=1; $THRESHOLD*$BZZ_PRECISION" | bc | xargs printf "%.0f"`

>&2 echo "NODE: $NODE"
>&2 echo "API: $DEBUG_API"
>&2 echo "MIN_AMOUNT=$MIN_AMOUNT ($THRESHOLD)"
>&2 echo "GAS_PRICE=$GAS_PRICE ($GAS_PRICE_GWEI gwei)"

function getPeers() {
  curl -s "$DEBUG_API/chequebook/cheque" | jq -r '.lastcheques | .[].peer'
}

function getBalances() {
  curl -s "$DEBUG_API/balances" |jq -r '.balances[] | .peer + "," + .balance'| grep -v -w 0
}

function getCumulativePayout() {
  local peer=$1
  local cumulativePayout=$(curl -s "$DEBUG_API/chequebook/cheque/$peer" | jq '.lastreceived.payout')
  if [ $cumulativePayout == null ]
  then
    echo 0
  else
    echo $cumulativePayout
  fi
}

function getLastCashedPayout() {
  local peer=$1
  local cashout=$(curl -s "$DEBUG_API/chequebook/cashout/$peer" | jq '.cumulativePayout')
  if [ $cashout == null ]
  then
    echo 0
  else
    echo $cashout
  fi
}

function getUncashedAmount() {
  local peer=$1
  local cumulativePayout=$(getCumulativePayout $peer)
  if [ $cumulativePayout == 0 ]
  then
    echo 0
    return
  fi

  cashedPayout=$(getLastCashedPayout $peer)
  cumulativePayout="${cumulativePayout:1:${#cumulativePayout}-2}"
  let uncashedAmount=$cumulativePayout-$cashedPayout
  echo $uncashedAmount
}

function cashout() {
  local peer=$1
  txHash=$(curl -s -XPOST -H "Gas-Price: $GAS_PRICE" "$DEBUG_API/chequebook/cashout/$peer" | jq -r .transactionHash) 

  echo cashing out cheque for $peer in transaction $txHash >&2

  result="$(curl -s $DEBUG_API/chequebook/cashout/$peer | jq .result)"
  while [ "$result" == "null" ]
  do
    sleep 5
    echo -n "."
    result=$(curl -s $DEBUG_API/chequebook/cashout/$peer | jq .result)
  done
}

function cashoutAll() {
  local minAmount=$1
  for peer in $(getPeers)
  do
    local uncashedAmount=$(getUncashedAmount $peer)
    if (( "$uncashedAmount" > $minAmount ))
    then
      echo "uncashed cheque for $peer ($uncashedAmount uncashed)" >&2
      cashout $peer
    fi
  done
}

function listAllUncashed() {
  for peer in $(getPeers)
  do
    local uncashedAmount=$(getUncashedAmount $peer)
    if (( "$uncashedAmount" > 0 ))
    then
      let bzz_amount=$uncashedAmount/BZZ_PRECISION
      echo "$peer: $bzz_amount"
    fi
  done
}

function listAllBalances() {  
  for balance in $(getBalances)
  do
    
    echo $balance | awk -F"," '{ printf("%s %.11f\n",$1,$2/1000000000000000.0)}'
    #echo $balance
  done
}


case $CMD in
  balance)
    # show balances under threshold 100000000 (negative == debt)
    listAllBalances
    ;;
  cashout)
    cashout $2
    ;;
  cashout-all)
    cashoutAll $MIN_AMOUNT
    ;;
  cheques|*)
    listAllUncashed
    ;;
esac

