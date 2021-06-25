#!/bin/bash

# List of accounts managed by Clef
# Prerequisite:
# 1. Current user must be in bee-clef group to access ipc (sudo usermod -a -G bee-clef $USER; sudo - $USER)

CLEF_DIR=/var/lib/bee-clef
CLEF_IPC=$CLEF_DIR/clef.ipc
echo '{"id": 1, "jsonrpc": "2.0", "method": "account_list"}' | nc -N -U $CLEF_IPC |jq -r .result[]
