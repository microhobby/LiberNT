# syntax=docker/dockerfile:1.7

FROM ubuntu:24.04

ARG ROSBE_BOOTSTRAP_URL=https://raw.githubusercontent.com/LiberNT/libernt-build-toolchain/main/rosbe-unix-bootstrap.sh

RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bison flex cmake ninja-build make ccache \
        gcc g++ libc6-dev pkg-config \
        python3 python3-mako python3-yaml python3-packaging \
        glslang-tools xxd \
        git curl wget ca-certificates xz-utils tar \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL "$ROSBE_BOOTSTRAP_URL" -o /tmp/rosbe-bootstrap.sh && \
    mkdir -p /opt/rosbe && \
    HOME=/tmp INSTALL_ROOT=/opt/rosbe BIN_DIR=/usr/local/bin sh /tmp/rosbe-bootstrap.sh && \
    rm -f /tmp/rosbe-bootstrap.sh && \
    test -x /opt/rosbe/llvm/bin/clang && \
    test -f /opt/rosbe/llvm/src/llvm-project/runtimes/CMakeLists.txt

RUN git config --system --add safe.directory '*'

ENV ROSBE_ROOT=/opt/rosbe \
    ROSBE_DOCKER_ACTIVE=1 \
    ROSBE_DOCKER_IMAGE=libernt-builder \
    CCACHE_DISABLE=1 \
    HOME=/tmp \
    PATH=/opt/rosbe/llvm-mingw/bin:/opt/rosbe/mingw-gcc/x86_64-w64-mingw32/bin:/opt/rosbe/mingw-gcc/i686-w64-mingw32/bin:/opt/rosbe/mingw-gcc/aarch64-w64-mingw32/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

COPY libernt-build.sh /usr/local/bin/libernt-build
RUN chmod 0755 /usr/local/bin/libernt-build

WORKDIR /libernt
ENTRYPOINT ["/usr/local/bin/libernt-build"]
CMD []
