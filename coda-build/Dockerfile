# Use Debian-based official GCC image
# see https://hub.docker.com/_/gcc/
FROM gcc

# Install Coda's build dependencies
RUN echo "deb http://deb.debian.org/debian/ stretch-backports main" > /etc/apt/sources.list.d/backports.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
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
    clang-format-6.0 \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*
