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
DUALITY_GRPC_ADDR="$NODE_IP:9081"



# Clean start
killall $DUALITY_BINARY &> /dev/null || true
rm -rf $DUALITY_HOME

# Build genesis file and node directory structure
$DUALITY_BINARY init --chain-id $DUALITY_CHAIN_ID $MONIKER --home $DUALITY_HOME
sleep 1

# Add consumer section to run as standalone chain
$DUALITY_BINARY add-consumer-section --home $DUALITY_HOME
sleep 1

# Create user account keypair
$DUALITY_BINARY keys add $GENACC $KEYRING --home $DUALITY_HOME --output json > $DUALITY_HOME/duality_keypair.json 2>&1

# Add account in genesis
$DUALITY_BINARY add-genesis-account $(jq -r .address $DUALITY_HOME/duality_keypair.json) 1000000000000stake --home $DUALITY_HOME

# add a second token to the balances to be able to perform deposits 
# &&
## append some custom fee tiers. Pipe the output to a new genesis file, replace the original, and rename it back to genesis.json
jq '.app_state.bank.balances[].coins += [{"denom": "stake2", "amount": "1000000000000"}]
       | .app_state.dex +=
 {
     "FeeTierList": [
        {"fee": "1", "id": "0"},
        {"fee": "3", "id": "1"}, 
        {"fee": "5", "id": "2"}, 
        {"fee": "10", "id": "3"}
    ],
    "FeeTierCount": "4",
}' $DUALITY_HOME/config/genesis.json > \
 $DUALITY_HOME/edited_genesis.json && mv $DUALITY_HOME/edited_genesis.json $DUALITY_HOME/config/genesis.json

# start the standalone duality consumer chain
$DUALITY_BINARY start \
       --home $DUALITY_HOME \
       --rpc.laddr tcp://${DUALITY_RPC_LADDR} \
       --grpc.address ${DUALITY_GRPC_ADDR} \
       --address tcp://${NODE_IP}:26645 \
       --p2p.laddr tcp://${NODE_IP}:26646 \
       --grpc-web.enable=false \
       --log_level trace \
       --trace \


