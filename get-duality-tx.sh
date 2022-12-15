#!/bin/bash
set -eux

DUALITY_HOME="$HOME/.duality"
DUALITY_CHAIN_ID="duality"
MONIKER="duality"
GENACC="duality-gen-account"
KEYRING="--keyring-backend test"
DUALITY_BINARY="dualityd"
NODE_IP="localhost"
DUALITY_RPC_LADDR="$NODE_IP:26648"


# perform a deposit transaction
USER_ADDRESS=$(jq '.app_state.auth.accounts[].address' $DUALITY_HOME/config/genesis.json | tr -d '"')
$DUALITY_BINARY tx dex deposit $USER_ADDRESS stake stake2 100000 100000 0 0 --from $USER_ADDRESS --generate-only > unsigned-tx.json
sleep 1
$DUALITY_BINARY tx sign unsigned-tx.json --from $GENACC $KEYRING --chain-id $DUALITY_CHAIN_ID --node tcp://${DUALITY_RPC_LADDR} > signed-tx.json
sleep 1
$DUALITY_BINARY tx encode signed-tx.json > encoded-signed-tx.txt