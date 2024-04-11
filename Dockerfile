FROM alpine:3.19

ENV VERSION=2.1.1 QT_PLUGIN_PATH=/home/ausweisapp/libs/plugins


RUN echo '@testing http://dl-cdn.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    apk --no-cache upgrade -a && \
    apk --no-cache add ccid pcsc-lite pcsc-lite-libs tini pcsc-cyberjack acsccid eudev-libs \
                       libxkbcommon libxcb xcb-util xcb-util-cursor xcb-util-renderutil xcb-util-xrm xcb-util-wm xcb-util-image xcb-util-keysyms \
                       mesa mesa-gl mesa-egl mesa-dri-gallium libx11 xkeyboard-config fontconfig freetype ttf-dejavu libxkbcommon-x11 sudo && \
    echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel && \
    adduser ausweisapp -G wheel -s /bin/sh -D

USER ausweisapp

# Install development stuff
# Get AusweisApp
# Build Libraries
# Build AusweisApp
# Clean up unused stuff
# Remove development stuff
RUN sudo apk --no-cache --virtual deps add patch cmake make ninja g++ pkgconf pcsc-lite-dev binutils-gold perl python3 wget \
                        mesa-dev libx11-dev libxkbcommon-dev fontconfig-dev freetype-dev \
                        xcb-util-wm-dev xcb-util-image-dev xcb-util-keysyms-dev \
                        xcb-util-renderutil-dev libxcb-dev && \
    \
    cd ~ && mkdir .config && mkdir build && cd build && \
    wget https://github.com/Governikus/AusweisApp2/releases/download/${VERSION}/AusweisApp-${VERSION}.tar.gz && \
    cmake -E tar xf AusweisApp-${VERSION}.tar.gz && \
    \
    cd ~/build && mkdir libs && cd libs && \
    cmake ../AusweisApp-${VERSION}/libs/ -DCMAKE_BUILD_TYPE=Release -DDESTINATION_DIR=/home/ausweisapp/libs && \
    cmake --build . -v  && \
    \
    cd ~/build && mkdir aa2 && cd aa2 && \
    cmake ../AusweisApp-${VERSION}/ -DCMAKE_BUILD_TYPE=MinSizeRel -DCMAKE_PREFIX_PATH=/home/ausweisapp/libs -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=ON -GNinja && \
    cmake --build . -v && sudo cmake --install . && \
    \
    cd ~ && rm -rf build && \
    cd libs && \
    rm -rf include bin doc mkspecs translations phrasebooks ssl && \
    cd lib && \
    rm -rf pkgconfig cmake *.a *.la *.prl && \
    rm -rf libQt6Nfc* libQt6Test* libQt6QuickTest* libQt6Bluetooth* && \
    strip *.so && \
    \
    sudo apk --no-cache del deps


VOLUME ["/home/ausweisapp/.config"]
ENTRYPOINT ["/sbin/tini", "--"]
CMD /usr/sbin/pcscd && /usr/local/bin/AusweisApp --address 0.0.0.0
