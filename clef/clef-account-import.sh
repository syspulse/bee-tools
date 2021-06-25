#!/bin/bash

# Add existing Ethereum address (keystore) into Clef 
# Prerequisite:
# 1. Current user must be in bee-clef group to access ipc (sudo usermod -a -G bee-clef $USER; sudo - $USER)
# 2. Keystore must be in geth format (NOT swarm format, use eth-keystore-write to create keystore)
# 3. Restart bee-clef (systemctl restart bee-clef)
# 4. Use -clef-signer-enable --clef-signer-ethereum-address=$ADDR to select adddress
# 5. Run with sudo
# 
# Example: 
# sudo ./clef-accounts-import.sh keystore.json

CLEF_DIR=/var/lib/bee-clef
CLEF_IPC=$CLEF_DIR/clef.ipc

KEYFILE=${1:-keystore.json}
SECRET=${2}

echo "Keystore: ${KEYFILE}"

ADDR="0x"`cat $KEYFILE |jq -r .address`

if [ "$SECRET" == "" ]; then
   SECRET=`cat $CLEF_DIR/password`
fi

echo "Address: $ADDR"
echo "Secret: $SECRET"

chmod 600 $KEYFILE
cp $KEYFILE $CLEF_DIR/keystore/
chown bee-clef:bee-clef $CLEF_DIR/keystore/$KEYFILE

clef --keystore $CLEF_DIR/keystore --configdir $CLEF_DIR --stdio-ui setpw $ADDR << EOF
$SECRET
$SECRET
$SECRET
EOF

clef --keystore $CLEF_DIR/keystore --configdir $CLEF_DIR --stdio-ui attest $(sha256sum /etc/bee-clef/rules.js | cut -d' ' -f1 | tr -d '\n') << EOF
$SECRET
EOF

sudo systemctl restart bee-clef