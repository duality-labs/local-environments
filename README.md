# sim-test

## Run a simulation on duality:

requirements: globaly available `dualityd` binary

### note:
the scripts need permission, they modify and delete files.
to give scripts permission:

`chmod +x start-duality-standalone.sh`

`chmod +x get-duality-tx.sh`

### setup

run the following to start the duality node. This re-initializes the `~/.duality` directory

 `./start-duality-standalone.sh`

in a new terminal, run :

`./get-duality-tx.sh`


This creates a few files. the important one is `encoded-signed-tx.txt`


run the go code:

`go run cmd/tx-sim/main.go`

This initializes a grpc server and tries to simulate the transaction using encoded transaction bytes in `encoded-signed-tx.txt`
