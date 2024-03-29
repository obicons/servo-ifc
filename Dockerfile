FROM ubuntu:20.04

RUN adduser --disabled-password --home /home/servo/ servo

RUN apt-get update &&                                       \
    DEBIAN_FRONTEND=noninteractive apt-get install -y       \
        autoconf                                            \
        build-essential                                     \
        clang                                               \
        curl                                                \
        cmake                                               \
        git                                                 \
        gstreamer1.0-nice                                   \
        gstreamer1.0-plugins-bad                            \
        libdbus-1-dev                                       \
        libfontconfig-dev                                   \
        libfreetype6-dev                                    \
        libglib2.0-dev                                      \
        libgstreamer1.0-dev                                 \
        libgstreamer-plugins-base1.0-dev                    \
        libgstreamer-plugins-bad1.0-dev                     \
        libssl-dev                                          \
        libunwind-dev                                       \
        libx11-dev                                          \
        libxcb-render0-dev                                  \ 
        libxcb-shape0-dev                                   \
        libxcb-xfixes0-dev                                  \
        m4                                                  \
        pkg-config                                          \
        software-properties-common                          \
        sudo                                                \
        time &&                                             \
    add-apt-repository ppa:deadsnakes/ppa &&                \
    DEBIAN_FRONTEND=noninteractive apt-get install -y       \
        python3.9-dev                                       \
        python3.9-full                                      \
        python3.9-venv &&                                   \
    rm -f /usr/bin/python3 &&                               \
    ln -s /usr/bin/python3.9 /usr/bin/python3 &&            \
    python3.9 -m ensurepip --upgrade &&                     \
    python3.9 -m pip install --upgrade pip &&               \
    python3.9 -m pip install setuptools virtualenv

RUN echo "servo ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

COPY --chown=servo:servo . /home/servo/servo
WORKDIR /home/servo/servo

USER servo
RUN python3.9 -m virtualenv -p python3.9                    \
        --system-site-package python/_virtualenv3.9 &&      \
    . python/_virtualenv3.9/bin/activate &&                 \
    python3.9 -m pip install -r python/requirements.txt &&  \
    ./mach bootstrap &&                                     \
    sudo rm -r /var/lib/apt/lists/*

RUN curl https://sh.rustup.rs > rustup-init.sh  &&   \
    sh ./rustup-init.sh -y

RUN python3.9 -m pip install voluptuous pyyaml

RUN cd /home/servo/servo/info-flow-library/ &&  \
    git init . &&                               \
    git apply ../ifc-patch.patch

RUN git config --global --add safe.directory /home/servo/servo &&   \
    . /home/servo/.cargo/env &&                                     \
    . python/_virtualenv3.9/bin/activate &&                         \
    ./mach build --dev

RUN mkdir /home/servo/results
VOLUME "/home/servo/results"
