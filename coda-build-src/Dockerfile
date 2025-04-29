# Use Debian-based official GCC image
# see https://hub.docker.com/_/gcc/
FROM gcc:14-bookworm

ENV PATH="/root/.local/bin:/usr/local/bin:/usr/bin:/bin"

# Install Coda's build and CI dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    bison \
    build-essential \
    ccache \
    doxygen \
    flex \
    fonts-freefont-ttf \
    fonts-liberation \
    git \
    graphviz \
    libffi8 \
    libgnutls28-dev \
    liblua5.1-0-dev \
    libncurses5-dev \
    libreadline-dev \
    libtool-bin \
    libuv1-dev \
    pkg-config \
    pipx \
    python3 \
    python3-build \
    systemd \
 && pipx install pre-commit \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
