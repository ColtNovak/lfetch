FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm \
    base-devel \
    git \
    sudo \
    cmake \
    make \
    libwebsockets \
    gcc \
    pkg-config \
    vte3 \
    json-c \
    openssl

RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/builder

USER builder
WORKDIR /home/builder

RUN git clone https://github.com/ColtNovak/lfetch.git && \
    cd lfetch && \
    sudo mkdir -p /usr/share/lfetch/logos && \
    sudo cp -r logos/* /usr/share/lfetch/logos/ && \
    sudo cp logos/arch /usr/share/lfetch/logos/Arch && \
    sudo sed -i "s/for distro in .*/for distro in Arch arch ARCH; do/" lfetch.sh && \
    sudo cp lfetch.sh /usr/local/bin/lfetch && \
    sudo chmod +x /usr/local/bin/lfetch

RUN git clone https://github.com/tsl0922/ttyd.git && \
    cd ttyd && \
    mkdir build && \
    cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make && \
    sudo make install

USER root

RUN pacman -Scc --noconfirm && \
    rm -rf /home/builder/* /var/cache/pacman/pkg/*

EXPOSE 8080
CMD ["sh", "-c", "ttyd -p 8080 -t titleFixed='Lfetch Terminal' -t reconnect=true -t reconnectTimeout=10 -t idleTimeout=0 bash -c 'while true; do clear; lfetch; sleep 30; done'"]
