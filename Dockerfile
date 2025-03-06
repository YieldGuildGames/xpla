#
# xpla localnet
#
# build:
#   docker build --force-rm -t xpladev/xpla .
# run:
#   docker run --rm -it --env-file=path/to/.env --name xpla-localnet xpladev/xpla

### BUILD
FROM golang:1.23-alpine3.21 AS build

# Create appuser.
RUN adduser -D -g '' valiuser
# Install required binaries
RUN apk add --update --no-cache zip git make cmake build-base linux-headers musl-dev libc-dev

WORKDIR /
RUN git clone --depth 1 https://github.com/microsoft/mimalloc; cd mimalloc; mkdir build; cd build; cmake ..; make -j$(nproc); make install
ENV MIMALLOC_RESERVE_HUGE_OS_PAGES=4

WORKDIR /workspace
# Copy source files
COPY . .
# Download dependencies and CosmWasm libwasmvm if found.
RUN set -eux; \    
    export ARCH=$(uname -m); \
    WASM_VERSION=v1.5.9; \
    wget -O /lib/libwasmvm_muslc.x86_64.a https://github.com/CosmWasm/wasmvm/releases/download/${WASM_VERSION}/libwasmvm_muslc.${ARCH}.a; \
    go mod download;
RUN go env

# Build executable
RUN LEDGER_ENABLED=false BUILD_TAGS=muslc LDFLAGS='-linkmode=external -extldflags "-L/mimalloc/build -lmimalloc -L/usr/lib -lwasmvm_muslc.x86_64 -Wl,-z,muldefs -static"' make install

# --------------------------------------------------------
FROM alpine:3.21 AS runtime

COPY --from=build /go/bin/xplad /usr/bin/xplad
#COPY --from=build /localnet/integration_test /opt/integration_test

# Expose Cosmos ports
EXPOSE 9090
EXPOSE 8545
EXPOSE 26656
#EXPOSE 26657

# Set entry point
CMD [ "/usr/bin/xplad", "version" ]
