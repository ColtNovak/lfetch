FROM arm64v8/alpine:latest
RUN apk update && apk add --no-cache bash git ttyd iproute2

RUN git clone https://github.com/ColtNovak/lfetch.git && \
    install -Dm755 lfetch/lfetch.sh /usr/local/bin/lfetch && \
    mkdir -p /usr/share/lfetch/logos && \
    cp -r lfetch/logos/* /usr/share/lfetch/logos/ && \
    rm -rf lfetch

EXPOSE 8080
CMD ["ttyd", "-p", "8080", "bash", "-c", "lfetch; exec bash"]
