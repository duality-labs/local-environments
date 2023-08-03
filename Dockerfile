
# Compile the hermes binary
FROM rust:1.71-alpine AS hermes-builder
RUN apk add --update alpine-sdk

# install dependencies (with cache) and build package
RUN --mount=type=cache,target=/usr/local/cargo/registry \
    cargo install ibc-relayer-cli --version 1.5.1 --bin hermes --locked


# Collect binaries together with scripts for testing
FROM golang:1.19-alpine

# add additional dependencies for the deployment scripts
RUN apk add bash curl jq;
COPY --from=ghcr.io/strangelove-ventures/heighliner/gaia:v10.0.1 /bin/gaiad /usr/bin
COPY --from=ghcr.io/duality-labs/duality:15cb02ba6b8c87723c7fd4bd4ce0c3bf660d6aff /bin/dualityd /usr/bin
COPY --from=hermes-builder /usr/local/cargo/bin/hermes /usr/bin

# add Go packages (with cache) for tx-sim
WORKDIR /workspace
COPY go.mod /workspace/
COPY go.sum /workspace/
RUN --mount=type=cache,target=/go/pkg/mod go mod download

COPY cmd /workspace/cmd
COPY scripts /workspace/scripts

CMD bash scripts/full-deployment/run.sh
