FROM debian:bookworm

ARG ARCH=arm64

RUN apt-get update -qq && \
    apt-get install -y --no-install-recommends debootstrap build-essential busybox-static && \
    rm -rf /var/lib/apt/lists/*

COPY input/ /input/

RUN mkdir -p /output && bash /input/main.sh
