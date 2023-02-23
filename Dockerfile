FROM golang:1.16-buster AS builder
WORKDIR       /build
RUN           apt-get update && apt-get install -qq --no-install-recommends \
                libasound2-dev=1.1.8-1 \
                curl \
                cargo=0.35.0-2 \
                git \
                libpulse-dev
RUN           git clone git://github.com/librespot-org/librespot
WORKDIR       /build/librespot
RUN           git checkout 295bda7e489715b9e6c27a262f9a4fcd12fb7632
RUN           cargo build -Z unstable-options --release --out-dir /dist --no-default-features --features pulseaudio-backend

FROM debian:buster as runtime
WORKDIR       /librespot
ARG           DEBIAN_FRONTEND="noninteractive"
RUN           apt-get update -qq \
              && apt-get install -qq --no-install-recommends \
                libasound2=1.1.8-1 \
                libpulse-dev \
                curl
COPY          --from=builder /dist .

RUN           apt-get -qq autoremove       \
              && apt-get -qq clean            \
              && rm -rf /var/lib/apt/lists/*  \
              && rm -rf /tmp/*                \
              && rm -rf /var/tmp/*

ENTRYPOINT    ["/startup.sh"]
CMD           [""]
