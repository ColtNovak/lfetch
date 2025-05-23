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

RUN yay -S lfetch ttyd --noconfirm \
    --answerclean All \
    --removemake \
    --cleanafter \
    --clean

RUN sudo rm -rf /var/cache/pacman/pkg/* && \
    rm -rf ~/.cache/yay

EXPOSE 8080

CMD ["ttyd", "-p", "8080", "lfetch"]
