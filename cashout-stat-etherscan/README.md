# Swarm Bee Cashout Statistics 

Shows cumulative gBZZ in/out chequebook transactions.

**NOTE**: Calculates totalPayout value from transactions (not cumulativePayout)

Requires ERC-20 transactions dump file

## Prerquisites

1. Ammonite ([https://ammonite.io/](https://ammonite.io/))


## Run

### Configure:

```sh
export ETH_ADDRESS="0x0000000000000000000000000000000000000001"
export CONTRACT_ADDRESS="0x0000000000000000000000000000000000000001"
```

**ETH_ADDRESS** - Swarm Ethereuem Account:

```
curl -s http://localhost:1635/addresses|jq .ethereum
```

**CONTRACT_ADDRESS** - Chequebook Account created by Swarm Account

```
curl -s http://localhost:1635/chequebook/address |jq .chequebookaddress
```

### Run script:

```sh
ammonite ./cashout-scan.sc <export.csv>
```

or

```sh
ammonite ./cashout-scan.sc <export.csv> [eth address] [contract address]
```
