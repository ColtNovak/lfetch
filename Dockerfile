FROM archlinux:latest

RUN pacman -Syu --noconfirm && \
    pacman -S --noconfirm base-devel git sudo && \
    rm -rf /var/cache/pacman/pkg/*

RUN useradd -m -G wheel -s /bin/bash user && \
    echo "%wheel ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER user
WORKDIR /home/user

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm --skippgpcheck && \
    cd .. && \
    rm -rf yay && \
    yay -Scc --noconfirm

RUN yay -S ttyd --noconfirm --cleanafter

RUN sudo rm -rf ~/.cache/yay/lfetch && \
    yay -S lfetch --noconfirm \
      --answerclean All \
      --answerdiff None \
      --cleanafter && \
    sudo pacman -Scc --noconfirm

CMD ["ttyd", "-p", "8080", "lfetch"]
