# Local Environments

## Global Requirements

To run the scripts in this repository, you can use the Docker image or install all software manually:

### Setup: Docker

You can build and run the full deployment for example like this:
```shell
docker build -t duality:local-environments .
# see Dockerfile for full list of available ports and their uses
# flag --rm removes the container on exit (useful to reset the environment)
docker run -it --init --rm \
  -p 26658:26658 \
  -p 9091:9091 \
  -p 26668:26668 \
  -p 9101:9101 \
  -p 26648:26648 \
  -p 9081:9081 \
  -p 26638:26638 \
  -p 9071:9071 \
  duality:local-environments

# to just enter the environment (eg. to explore tx-sim) you can use
docker run -it duality:local-environments /bin/bash
```

### Setup: OSX / Linux
- Go v1.19
- jq
- dualityd

To install Go and jq on OSX or Linux, you can use the following commands:

```bash
brew install go@1.19
brew install jq
```

to get `dualityd` binary follow [installation guide](https://github.com/duality-labs/duality/blob/main/readme.md)

## Giving Scripts Permission
Some of the scripts in this repository modify and delete files, so you will need to give them permission to run. 
To do this, use the following command:

```bash
chmod +x {script_name}.sh
```

## Running a standalone duality consumer chain:
To run a standalone Duality consumer chain, use the following script:


 ```bash
scripts/standalone-node/start-duality-standalone.sh
```
:warning: This script reinitializes the .duality directory

#### Optional: setup Deposit TX simulation

To set up a simulation of a deposit transaction, open a new terminal and run the following script:
 ```bash
scripts/standalone-node/get-duality-tx.sh
```

This script creates a few files, including encoded-signed-tx.txt, which is the raw signed transaction bytes to send over to the simulation request. To run the simulation, use the following command:


```bash
go run cmd/tx-sim/main.go
```
## Running a Full Duality Deployment:
To run a full Duality deployment, you will need the following additional software:

- `dualityd` (v0.3.4 as used in duality-testnet-1 on Interchain Security)
- `gaiad` (v10.0.1 as used in duality-testnet-1 on Interchain Security)
- `hermes`: IBC relayer (v1.5.1 as used in duality-testnet-1 on Interchain Security)
  - Rust (optional, v1.70 or later)

To install dualityd, follow the instructions [here](https://github.com/duality-labs/duality/tree/v0.3.4).
  - or use Heighliner Docker image [ghcr.io/duality-labs/duality:15cb02ba6b8c87723c7fd4bd4ce0c3bf660d6aff](https://github.com/orgs/duality-labs/packages/container/duality/108783229?tag=15cb02ba6b8c87723c7fd4bd4ce0c3bf660d6aff) (specific commit for v0.3.4 release as specified by GitHub actions on the `main` branch commit or the release)

To install gaiad, follow the instructions [here](https://hub.cosmos.network/main/getting-started/installation.html#install-the-binaries).
  - or use `make install` from [source code](https://github.com/cosmos/gaia/tree/v10.0.1)
  - or use Heighliner Docker image [ghcr.io/strangelove-ventures/heighliner/gaia:v10.0.1](https://github.com/strangelove-ventures/heighliner/pkgs/container/heighliner%2Fgaia/107555011?tag=v10.0.1)

To install Hermes, follow the instructions [here](https://hermes.informal.systems/quick-start/installation.html).
  - or install Rust and use `cargo install ibc-relayer-cli --version 1.5.1 --bin hermes --locked`
  - or use Docker image: [informalsystems/hermes:1.5.1](https://hub.docker.com/layers/informalsystems/hermes/1.5.1/images/sha256-3eb82f872b6f116f4a71c350292aff551381b65eeb7c11867f8cd33090c6eb0b?context=explore)
    - this image can be problematic when running on Alpine Linux on an ARM CPU

To install Rust, follow the instructions [here](https://www.rust-lang.org/tools/install).

To run a full Duality deployment, use the following script:

 ```bash
scripts/full-deployment/run.sh
```
This script will:

- Start a provider chain with 2 nodes
- Pass a Duality consumer chain governance proposal
- Start the Duality chain with 2 nodes

:warning: The nodes will run idle and continue to consume resources and storage until terminated. 
To kill the processes, use the following commands:
```bash
killall dualityd &> /dev/null || true
killall interchain-security-pd &> /dev/null || true
```
