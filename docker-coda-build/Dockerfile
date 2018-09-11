# Use Debian-based official GCC image
# see https://hub.docker.com/_/gcc/
FROM gcc

# Install Coda's build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    automake \
    bison \
    ccache \
    doxygen \
    flex \
    fonts-freefont-ttf \
    fonts-liberation \
    graphviz \
    pkg-config \
    python \
    liblua5.1-0-dev \
    libncurses5-dev \
    libreadline-dev \
    libtool-bin \
    libuv1-dev \
    systemd \
 && rm -rf /var/lib/apt/lists/*
