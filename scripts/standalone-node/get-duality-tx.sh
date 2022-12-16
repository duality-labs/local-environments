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

script_dir=$(dirname "$0")
rm -rf $script_dir/tx-data
mkdir "$script_dir/tx-data"

# perform a deposit transaction
USER_ADDRESS=$(jq '.app_state.auth.accounts[].address' $DUALITY_HOME/config/genesis.json | tr -d '"')
$DUALITY_BINARY tx dex deposit $USER_ADDRESS stake stake2 100000 100000 0 0 --from $USER_ADDRESS --generate-only > $script_dir/tx-data/unsigned-tx.json
sleep 1
$DUALITY_BINARY tx sign $script_dir/tx-data/unsigned-tx.json --from $GENACC $KEYRING --chain-id $DUALITY_CHAIN_ID --node tcp://${DUALITY_RPC_LADDR} > $script_dir/tx-data/signed-tx.json
sleep 1
$DUALITY_BINARY tx encode $script_dir/tx-data/signed-tx.json > $script_dir/tx-data/encoded-signed-tx.txt