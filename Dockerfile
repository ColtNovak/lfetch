FROM --platform=linux/amd64 archlinux:latest

RUN pacman -Syu --noconfirm --needed \
    base-devel git sudo fakeroot awk grep procps-ng

RUN useradd -m builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm --skippgpcheck && \
    cd .. && \
    rm -rf yay

RUN yay -S --noconfirm ttyd lfetch --removemake --answerclean All --cleanafter

RUN sudo rm -rf /var/cache/pemu-user-static
EXPOSE 8080
CMD ["ttyd", "-p", "8080", "lfetch"]
