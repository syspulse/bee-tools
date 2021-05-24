#!/bin/bash
export ETH_RPC_URL=http://localhost:18545
export ETH_FROM=${1:-0x0000000000000000000000000000000000000001}

seth call 0x60c2c1370596533ba21633898c88903f426cdee7 "totalPaidOut()(uint256)"
