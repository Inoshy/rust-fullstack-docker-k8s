FROM rust:1.47.0-slim-buster as builder

# copy files from this directory '.' to '/var/rfs'
ADD . /var/rfs

# set cwd for RUN and CMD
WORKDIR /var/rfs

RUN apt-get update && apt-get -y install pkg-config libssl-dev node

RUN cargo fetch

RUN cargo build --release

################
# second stage #
FROM rust:1.47.0-slim-buster

RUN mkdir /var/rfs
WORKDIR /var/rfs

# adjust permissions
RUN groupadd --gid 1000 rust \
	&& useradd --uid 1000 --gid rust --shell /bin/bash --create-home rust

RUN chown -R rust:rust /var/rfs

COPY --from=builder /var/rfs/target/release/rust_fullstack_docker_k8s .
COPY --from=builder /var/rfs/config/ config
RUN mkdir ./artifacts

USER rust

# run the daemon
ENTRYPOINT ["./rust_fullstack_docker_k8s"]

# profit || throw new Error('unable to profit')