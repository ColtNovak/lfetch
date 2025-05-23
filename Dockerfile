FROM --platform=linux/amd64 archlinux:latest

COPY qemu-x86_64-static /usr/bin/

RUN pacman -Syu --noconfirm --needed \
    base-devel \
    git \
    sudo \
    fakeroot \
    awk \
    grep \
    procps-ng

RUN groupadd -r builder && \
    useradd -m -r -g builder builder && \
    echo "builder ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

USER builder
WORKDIR /home/builder

RUN git clone https://aur.archlinux.org/yay.git && \
    cd yay && \
    makepkg -si --noconfirm --skippgpcheck && \
    cd .. && \
    rm -rf yay

RUN yay -S --noconfirm \
    ttyd \
    lfetch \
    --removemake \
    --answerclean All \
    --cleanafter

RUN sudo rm -rf \
    /var/cache/pacman/pkg/* \
    ~/.cache/yay

EXPOSE 8080
CMD ["ttyd", "-p", "8080", "lfetch"]
