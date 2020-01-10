FROM ubuntu:18.04

ARG CHROMIUM_TAG=80.0.3987.1
RUN apt-get update && apt-get -y dist-upgrade && \
    debian_frontend=noninteractive apt-get install -y tzdata && \
    echo "APT::Get::Assume-Yes \"true\";" >> /etc/apt/apt.conf && \
    echo "APT::Get::force-yes \"true\";" >> /etc/apt/apt.conf && \
    apt-get install -y python git-core gnupg flex bison gperf build-essential zip \
        curl zlib1g-dev gcc-multilib g++-multilib libc6-dev-i386 lib32ncurses5-dev \
        x11proto-core-dev libx11-dev lib32z-dev libgl1-mesa-dev libxml2-utils xsltproc unzip wget && \
    wget 'https://storage.googleapis.com/git-repo-downloads/repo' -P /usr/local/bin && \
    chmod +x /usr/local/bin/repo && \
        apt-get install -y openjdk-8-jdk bc bison build-essential curl flex g++-multilib \
        gcc-multilib gnupg gperf imagemagick lib32ncurses5-dev lib32readline-dev lib32z1-dev \
        liblz4-tool libncurses5-dev libsdl1.2-dev libssl-dev libwxgtk3.0-dev libxml2 \
        libxml2-utils lzop pngcrush rsync schedtool squashfs-tools xsltproc yasm zlib1g-dev \
        lsb-release sudo bash vim && \
    git config --global user.name "buildman" && git config --global user.email "buildman@localhost" && \
    git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git /depot_tools && \
    chmod -R 777 /depot_tools && \
    wget -O install-build-deps-android.b64 https://chromium.googlesource.com/chromium/src/+/refs/tags/${CHROMIUM_TAG}/build/install-build-deps-android.sh?format=TEXT && \
    wget -O install-build-deps.b64 https://chromium.googlesource.com/chromium/src/+/refs/tags/${CHROMIUM_TAG}/build/install-build-deps.sh?format=TEXT && \
    base64 -d install-build-deps-android.b64 > install-build-deps-android.sh && \
    base64 -d install-build-deps.b64 > install-build-deps.sh && \
    chmod +x *.sh && \
    ./install-build-deps.sh --no-chromeos-fonts && \
    ./install-build-deps-android.sh && \
    rm *.b64 && \
    rm *.sh && \
    apt-get autoremove && \
    rm -rf /var/lib/apt/lists/*

COPY ./docker-entrypoint.sh /docker-entrypoint.sh

ENV PATH $PATH:/depot_tools
ENV HOME /root/
ENV EDITOR vim

RUN useradd -m buildman && \
    echo "buildman ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
    mkdir /vanadium && \
    chmod +rx /docker-entrypoint.sh && \
    chmod -R 777 /root/

VOLUME /vanadium

USER buildman

CMD ["/docker-entrypoint.sh", "$@"]
