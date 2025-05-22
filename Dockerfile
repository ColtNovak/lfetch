FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git sudo

RUN useradd -m -G wheel -s /bin/bash builder && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder
RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm --skippgpcheck && \
    cd .. && \
    rm -rf yay

RUN yay -S lfetch --noconfirm --answerclean All --removemake --cleanafter && \
    sudo rm -rf /var/cache/pacman/pkg/* ~/.cache/yay

USER root
RUN mkdir -p /usr/share/lfetch/logos && \
    cp -r /usr/lib/lfetch/logos/* /usr/share/lfetch/logos/ && \
    chmod -R 755 /usr/share/lfetch/logos
RUN pacman -S --noconfirm ttyd

RUN pacman -Scc --noconfirm && \
    rm -rf /var/cache/pacman/pkg/* /home/builder/*

EXPOSE 8080
CMD ["ttyd", "-p", "8080", "lfetch"]
