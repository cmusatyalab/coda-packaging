# Use Debian-based official GCC image
# see https://hub.docker.com/_/gcc/
FROM gcc:9-buster

# Install Coda's build and CI dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    bison \
    build-essential \
    ccache \
    clang-format-6.0 \
    doxygen \
    flex \
    fonts-freefont-ttf \
    fonts-liberation \
    git \
    graphviz \
    libffi6 \
    libgnutls28-dev \
    liblua5.1-0-dev \
    libncurses5-dev \
    libreadline-dev \
    libtool-bin \
    libuv1-dev \
    pkg-config \
    python3 \
    systemd \
    python3-attr \
    python3-dev \
    python3-pip \
    python3-setuptools \
    python3-wheel \
 && pip3 install pre-commit \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
