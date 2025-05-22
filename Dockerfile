FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git sudo

RUN useradd -m -G wheel -s /bin/bash user && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user
WORKDIR /home/user

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm && \
    cd .. && \
    rm -rf yay && \
    rm -rf ~/.cache/yay

RUN yay -S lfetch --noconfirm --clean && \
    sudo rm -rf /var/cache/pacman/pkg/* && \
    rm -rf ~/.cache/yay && \
    rm -rf ~/.build

CMD ["lfetch"]
