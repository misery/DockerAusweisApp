FROM alpine:3.10
MAINTAINER André Klitzing <aklitzing@gmail.com>

ENV VERSION=1.18.2 QT_PLUGIN_PATH=/home/ausweisapp/libs/plugins


RUN echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk --no-cache upgrade -a && \
    apk --no-cache add ccid pcsc-lite pcsc-lite-libs tini pcsc-cyberjack acsccid \
                       libxkbcommon xcb-util xcb-util-cursor xcb-util-renderutil xcb-util-xrm xcb-util-wm xcb-util-image xcb-util-keysyms \
                       mesa mesa-gl libx11 xkeyboard-config fontconfig freetype ttf-dejavu libxkbcommon-x11 sudo && \
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    adduser ausweisapp -G wheel -s /bin/sh -D

USER ausweisapp

# Install development stuff
# Get AusweisApp2
# Build Libraries
# Build AusweisApp2
# Clean up unused stuff
# Remove development stuff
RUN sudo apk --no-cache --virtual deps add patch cmake make g++ pkgconf pcsc-lite-dev binutils-gold perl python2 wget \
                        mesa-dev libx11-dev libxkbcommon-dev xcb-util-wm-dev xcb-util-image-dev xcb-util-keysyms-dev \
                        libxkbcommon-dev fontconfig-dev freetype-dev && \
    \
    cd ~ && mkdir build && cd build && \
    wget https://github.com/Governikus/AusweisApp2/releases/download/${VERSION}/AusweisApp2-${VERSION}.tar.gz && \
    cmake -E tar xf AusweisApp2-${VERSION}.tar.gz && \
    \
    cd ~/build && mkdir libs && cd libs && \
    cmake ../AusweisApp2-${VERSION}/libs/ -DCMAKE_BUILD_TYPE=Release -DDESTINATION_DIR=/home/ausweisapp/libs && \
    make && \
    \
    cd ~/build && mkdir aa2 && cd aa2 && \
    cmake ../AusweisApp2-${VERSION}/ -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_PREFIX_PATH=/home/ausweisapp/libs && \
    make && \
    cd src && mv AusweisApp2 AusweisApp2.rcc config.json translations ~ && \
    \
    cd ~ && rm -rf build && \
    strip AusweisApp2 && \
    cd libs && \
    rm -rf include bin doc mkspecs translations phrasebooks ssl qml && \
    cd lib && \
    rm -rf pkgconfig cmake *.a *.la *.prl && \
    rm -rf libQt5Designer* libQt5Help* libQt5Nfc* libQt5Sensors* libQt5Sql* libQt5Test* libQt5Multimedia* libQt5CLucene* libQt5Bluetooth* && \
    strip *.so && \
    \
    sudo apk --no-cache del deps


ENTRYPOINT ["/sbin/tini", "--"]
CMD /usr/sbin/pcscd && /home/ausweisapp/AusweisApp2
