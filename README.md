# Local Environments

### Global requirements:
```bash
## os: OSX / Linux

# go v1.18
brew install go@1.18
# jq
brew install jq
```
``` bash
# dualityd
```
to get dualityd binary follow [installation guide](https://github.com/duality-labs/duality/blob/main/readme.md)

some scripts need permission as they modify and delete files.
to give scripts permission:

```bash
chmod +x {script_name}.sh
```

## Run a standalone chain on duality:
 ```bash
# this reinitializes the .duality directory. Use with caution
./start-duality-standalone.sh
```

#### Optional: setup Deposit TX simulation

in a new terminal:

 ```bash
./get-duality-tx.sh
```

This creates a few files. the important one is `encoded-signed-tx.txt`
This is the raw signed transaction bytes to send over to the simulation request

run the simulation:

```bash
go run cmd/tx-sim/main.go
```
## Run a full Duality deployment:
### Additional requirements:
```bash
#interchain security provider chain binary
interchain-security-pd
#hermes IBC relayer
hermes v0.15.0
#rust required by Hermes
rust v1.65
```
[install](https://github.com/cosmos/interchain-security/blob/main/README.md) interchain-security-pd 

[install](https://www.rust-lang.org/tools/install) rust 

[install](https://hermes.informal.systems/quick-start/installation.html) hermes 

 ```bash
./run.sh
```
