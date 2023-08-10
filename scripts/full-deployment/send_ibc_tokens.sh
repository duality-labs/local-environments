#!/bin/bash
set -e

CONSUMER_HOME="$HOME/.duality"
CONSUMER_HOME1="$HOME/.duality1"
PROVIDER_CHAIN_ID="provider"
CONSUMER_CHAIN_ID="duality"
MONIKER="duality"
VALIDATOR="validator"
VALIDATOR1="validator1"
KEYRING="--keyring-backend test"
TX_FLAGS="--gas-adjustment 100 --gas auto"
PROVIDER_BINARY=${PROVIDER_BINARY:-gaiad}
CONSUMER_BINARY=${CONSUMER_BINARY:-dualityd}
NODE_IP="${NODE_IP:-localhost}"
PROVIDER_RPC_LADDR="$NODE_IP:26658"
PROVIDER_GRPC_ADDR="$NODE_IP:9091"
PROVIDER_REST_ADDR="$NODE_IP:1318"
PROVIDER_RPC_LADDR1="$NODE_IP:26668"
PROVIDER_GRPC_ADDR1="$NODE_IP:9101"
PROVIDER_REST_ADDR1="$NODE_IP:1328"
CONSUMER_RPC_LADDR="$NODE_IP:26648"
CONSUMER_GRPC_ADDR="$NODE_IP:9081"
CONSUMER_REST_ADDR="$NODE_IP:1308"
CONSUMER_RPC_LADDR1="$NODE_IP:26638"
CONSUMER_GRPC_ADDR1="$NODE_IP:9071"
CONSUMER_REST_ADDR1="$NODE_IP:1298"
CONSUMER_USER="consumer"
PROVIDER_HOME="$HOME/.provider"
PROVIDER_HOME1="$HOME/.provider1"
PROVIDER_NODE_ADDRESS="tcp://localhost:26658"

# the result of provider REST query
# http://localhost:1318/ibc/core/channel/v1/channels
# {
#   "channels": [
#     {
#       "state": "STATE_OPEN",
#       "ordering": "ORDER_ORDERED",
#       "counterparty": {
#         "port_id": "consumer",
#         "channel_id": "channel-0"
#       },
#       "connection_hops": [
#         "connection-0"
#       ],
#       "version": "\n-cosmos1ap0mh6xzfn8943urr84q6ae7zfnar48am2erhd\u0012\u00011",
#       "port_id": "provider",
#       "channel_id": "channel-0"
#     }
#   ],
#   "pagination": {
#     "next_key": null,
#     "total": "1"
#   },
#   "height": {
#     "revision_number": "0",
#     "revision_height": "12"
#   }
# }

# the result of provider REST query
# http://localhost:1308/ibc/core/channel/v1/channels
# {
#   "channels": [
#     {
#       "state": "STATE_OPEN",
#       "ordering": "ORDER_ORDERED",
#       "counterparty": {
#         "port_id": "provider",
#         "channel_id": "channel-0"
#       },
#       "connection_hops": [
#         "connection-0"
#       ],
#       "version": "\n-cosmos1ap0mh6xzfn8943urr84q6ae7zfnar48am2erhd\u0012\u00011",
#       "port_id": "consumer",
#       "channel_id": "channel-0"
#     },
#     {
#       "state": "STATE_INIT",
#       "ordering": "ORDER_UNORDERED",
#       "counterparty": {
#         "port_id": "transfer",
#         "channel_id": ""
#       },
#       "connection_hops": [
#         "connection-0"
#       ],
#       "version": "ics20-1",
#       "port_id": "transfer",
#       "channel_id": "channel-1"
#     }
#   ],
#   "pagination": {
#     "next_key": null,
#     "total": "2"
#   },
#   "height": {
#     "revision_number": "0",
#     "revision_height": "12"
#   }
# }


# Wait for a while until the transfer channel is open
n=0
until [ "$n" -ge 60 ]
do
    sleep 1
    # find current provider transfer port state
    CHANNEL_STATES=$( $PROVIDER_BINARY --home $PROVIDER_HOME --output json q ibc channel channels )
    TRANSFER_PORT_STATE=$( echo $CHANNEL_STATES | jq -r '.channels[] | select(.port_id == "transfer") | .state' )
    echo "transport channel state: ${TRANSFER_PORT_STATE:-...}"
    # break loop if port state is open
    [ "$TRANSFER_PORT_STATE" = "STATE_OPEN" ] && break
    n=$((n+1))
    # print error if last loop was not successful
    [ "$n" -ge 30 ] && echo "transport channel open state was not reached" && exit 1
done

# create IBC transfer between running Provider and Consumer chains
SRC_PORT=transfer
SRC_CHANNEL=channel-1
SRC_DENOM=stake
IBC_TRANSFER_AMOUNT=100000000
SENDER=$( $PROVIDER_BINARY --home $PROVIDER_HOME --keyring-backend test keys show -a $VALIDATOR )
RECEIVER=$( $CONSUMER_BINARY --home $CONSUMER_HOME --keyring-backend test keys show -a $CONSUMER_USER )

# send tokens
$PROVIDER_BINARY --home $PROVIDER_HOME --keyring-backend test --chain-id $PROVIDER_CHAIN_ID \
  tx ibc-transfer transfer $SRC_PORT $SRC_CHANNEL $RECEIVER $IBC_TRANSFER_AMOUNT$SRC_DENOM --from $SENDER \
  -b block -y

# check that the tockens are received correctly
IBC_DENOM_TRACE=$SRC_PORT/$SRC_CHANNEL/$SRC_DENOM
# to check for the transferred IBC token denom we find the IBC hash deterministically ahead of it appearing on the chain
IBC_DENOM_HASH=ibc/$( echo -n $IBC_DENOM_TRACE | sha256sum | cut -d " " -f1 | tr '[:lower:]' '[:upper:]' )

# Wait for a while until the IBC token has been received on the consumer chain
n=0
until [ "$n" -ge 60 ]
do
    sleep 1
    # find current provider transfer port state
    RECEIVED_IBC_DENOM=$( $CONSUMER_BINARY --home $CONSUMER_HOME --output json q bank balances $RECEIVER --denom $IBC_DENOM_HASH | jq -r '.amount' )
    echo "Tokens ($IBC_DENOM_TRACE) received by \"$RECEIVER\": $RECEIVED_IBC_DENOM"
    # break loop if port state is open
    [ $RECEIVED_IBC_DENOM -ge $IBC_TRANSFER_AMOUNT ] && break
    n=$((n+1))
    [ "$n" -ge 30 ] && echo "Token poll timed out" && exit 1
done
