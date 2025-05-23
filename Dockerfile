FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git  && \
    useradd -m -G wheel -s /bin/bash builder && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm --skippgpcheck && \
    cd .. && \
    rm -rf yay && \
    sudo rm -rf /var/cache/pacman/pkg/*
RUN rm -rf ~/.cache/yay/lfetch ~/.cache/yay/ttyd
RUN rm -rf /usr/bin/lfetch

RUN yay -S lfetch ttyd --noconfirm \
    --answerclean All \
    --removemake \
    --cleanafter \
    --clean && \
    sudo rm -rf /var/cache/pacman/pkg/* && \
    rm -rf ~/.cache/yay/*

EXPOSE 8080
CMD ["ttyd", "-p", "8080", "lfetch"]


