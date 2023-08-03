# Local Environments

## Global Requirements

To run the scripts in this repository, you need to have the following software installed:

### OSX / Linux
- Go v1.18
- jq
- dualityd

To install Go and jq on OSX or Linux, you can use the following commands:

```bash
brew install go@1.18
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

- gaiad (v10.0.1 as used in duality-testnet-1 on Interchain Security)
- Hermes IBC relayer (v0.15.0)
- Rust (v1.65 or later)

To install gaiad, follow the instructions [here](https://hub.cosmos.network/main/getting-started/installation.html#install-the-binaries).
  - or use `make install` from [source code](https://github.com/cosmos/gaia/tree/v10.0.1)
  - or use Heighliner Docker image [ghcr.io/strangelove-ventures/heighliner/gaia:v10.0.1](https://github.com/strangelove-ventures/heighliner/pkgs/container/heighliner%2Fgaia/107555011?tag=v10.0.1)

To install Rust, follow the instructions [here](https://www.rust-lang.org/tools/install).

To install Hermes, follow the instructions [here](https://hermes.informal.systems/quick-start/installation.html).

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
