FROM alpine:3.14
MAINTAINER André Klitzing <aklitzing@gmail.com>

ENV VERSION=1.22.2 QT_PLUGIN_PATH=/home/ausweisapp/libs/plugins


RUN echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk --no-cache upgrade -a && \
    apk --no-cache add ccid pcsc-lite pcsc-lite-libs tini pcsc-cyberjack acsccid eudev-libs \
                       libxkbcommon libxcb xcb-util xcb-util-cursor xcb-util-renderutil xcb-util-xrm xcb-util-wm xcb-util-image xcb-util-keysyms \
                       mesa mesa-gl mesa-dri-gallium mesa-dri-classic libx11 xkeyboard-config fontconfig freetype ttf-dejavu libxkbcommon-x11 sudo && \
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    adduser ausweisapp -G wheel -s /bin/sh -D

USER ausweisapp

# Install development stuff
# Get AusweisApp2
# Build Libraries
# Build AusweisApp2
# Clean up unused stuff
# Remove development stuff
RUN sudo apk --no-cache --virtual deps add patch cmake make ninja g++ pkgconf pcsc-lite-dev binutils-gold perl python3 wget \
                        mesa-dev libx11-dev libxkbcommon-dev fontconfig-dev freetype-dev \
                        xcb-util-wm-dev xcb-util-image-dev xcb-util-keysyms-dev \
                        xcb-util-renderutil-dev libxcb-dev && \
    \
    cd ~ && mkdir build && cd build && \
    wget https://github.com/Governikus/AusweisApp2/releases/download/${VERSION}/AusweisApp2-${VERSION}.tar.gz && \
    wget https://github.com/Governikus/AusweisApp2/commit/08d15199489e13b084fa515a6490787bcf3414fb.patch && \
    cmake -E tar xf AusweisApp2-${VERSION}.tar.gz && \
    cd AusweisApp2-${VERSION} && \
    patch -p1 -i ../08d15199489e13b084fa515a6490787bcf3414fb.patch && \
    \
    cd ~/build && mkdir libs && cd libs && \
    cmake ../AusweisApp2-${VERSION}/libs/ -DCMAKE_BUILD_TYPE=Release -DDESTINATION_DIR=/home/ausweisapp/libs && \
    cmake --build . -v  && \
    \
    cd ~/build && mkdir aa2 && cd aa2 && \
    cmake ../AusweisApp2-${VERSION}/ -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_PREFIX_PATH=/home/ausweisapp/libs -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON -GNinja && \
    cmake --build . -v && sudo cmake --install . && \
    \
    cd ~ && rm -rf build && \
    cd libs && \
    rm -rf include bin doc mkspecs translations phrasebooks ssl && \
    cd lib && \
    rm -rf pkgconfig cmake *.a *.la *.prl && \
    rm -rf libQt5Designer* libQt5Help* libQt5Nfc* libQt5Sensors* libQt5Sql* libQt5Test* libQt5Multimedia* libQt5CLucene* libQt5Bluetooth* && \
    strip *.so && \
    \
    sudo apk --no-cache del deps


ENTRYPOINT ["/sbin/tini", "--"]
CMD /usr/sbin/pcscd && /usr/local/bin/AusweisApp2
