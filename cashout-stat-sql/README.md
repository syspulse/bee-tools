# Swarm Bee Cashout Statistics 

Shows cumulative gBZZ in/out chequebook transactions.

**NOTE**: Calculates cumulativePayout value from transactions (not totalPayout)

Uses [https://www.anyblockanalytics.com](https://www.anyblockanalytics.com). 

**Requires account (free) on [https://www.anyblockanalytics.com](https://www.anyblockanalytics.com)**

## Prerquisites

1. bc (calculator)
2. psql (Postgres Client)
3. [https://www.anyblockanalytics.com](https://www.anyblockanalytics.com) Account with DB credentials (user/password)

**NOTE**: Account with 120 queries per hour is free


## Configure

Copy env-template.sh to env.sh

```sh
export ETH_ADDRESS="0x0000000000000000000000000000000000000001"
export CONTRACT_ADDRESS="0x0000000000000000000000000000000000000001"

export DB_USER="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
export DB_PASS="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"

export DB_DATABASE="ethereum_ethereum_goerli"
export DB_HOST="sql.anyblock.net"
```

**ETH_ADDRESS** - Swarm Ethereuem Account:

```
curl -s http://localhost:1635/addresses|jq .ethereum
```

**CONTRACT_ADDRESS** - Chequebook Account created by Swarm Account

```
curl -s http://localhost:1635/chequebook/address |jq .chequebookaddress
```

Apply environment:

```sh
source env.sh
```


## Run


```sh
./cashout-stat.sh
```

or

```sh
./cashout-stat.sh [swarm address] [contract address]
```

or

```sh
DB_USER=user DB_PASS=pass ./cashout-stat.sh [swarm address] [contract address]
```
