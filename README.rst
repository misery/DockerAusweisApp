.. image:: https://img.shields.io/badge/license-EUPL_v1.2-blue.svg
   :target: https://raw.githubusercontent.com/misery/DockerAusweisApp2/master/LICENSE.txt

.. image:: https://img.shields.io/badge/docker_pulls-aklitzing/ausweisapp2-blue.svg
   :target: https://hub.docker.com/r/aklitzing/ausweisapp2/


AusweisApp in Docker (Linux)
============================
This docker image contains a minimal OS (AlpineLinux) as a base image.

It builds Qt6 and OpenSSL with the cmake library-script of AusweisApp
and builds AusweisApp itself.

Also it contains ``pcscd`` with some additional card reader driver.


Build
-----
You can build the image locally with podman:

::

   cd /path/to/DockerAusweisApp
   podman build -t ausweisapp-multistage .

The Dockerfile uses a multistage build to keep the final image small.
Build dependencies are only installed in the first stage and not included in the final image.


Start
-----
You could start AusweisApp with this command:

::

   docker run --name ausweisapp -p 127.0.0.1:24727:24727 -e DISPLAY=$DISPLAY -e LANG=$LANG -v /tmp/.X11-unix:/tmp/.X11-unix --privileged aklitzing/ausweisapp2


X11 (Xorg)
~~~~~~~~~~
For X11, you need to allow the container to access your X server.

**Option 1: xhost (simple)**

Allow local root connections:

::

   xhost local:root

Or allow your specific user (more secure):

::

   xhost +SI:localuser:$(whoami)

Then run the container:

::

   podman run --name ausweisapp -p 127.0.0.1:24727:24727 \
     -e DISPLAY=$DISPLAY -e LANG=$LANG \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     --privileged aklitzing/ausweisapp2

**Option 2: Xauthority (more secure)**

Mount your Xauthority file into the container:

::

   podman run --name ausweisapp -p 127.0.0.1:24727:24727 \
     -e DISPLAY=$DISPLAY -e LANG=$LANG \
     -e XAUTHORITY=/home/ausweisapp/.Xauthority \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     -v $HOME/.Xauthority:/home/ausweisapp/.Xauthority:ro \
     --privileged aklitzing/ausweisapp2


Wayland
~~~~~~~
For Wayland compositors (e.g., GNOME Shell, KDE Plasma, Sway), you need to expose the Wayland socket and set the appropriate environment variables.

**Option 1: XWayland (if available)**

If your compositor supports XWayland, you can use the X11 method above.

**Option 2: Native Wayland**

Expose the Wayland socket and set the platform:

::

   podman run --name ausweisapp -p 127.0.0.1:24727:24727 \
     -e DISPLAY=$DISPLAY -e LANG=$LANG \
     -e WAYLAND_DISPLAY=$WAYLAND_DISPLAY \
     -e QT_QPA_PLATFORM=wayland \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     -v $XDG_RUNTIME_DIR/$WAYLAND_DISPLAY:/run/user/1000/$WAYLAND_DISPLAY \
     --privileged aklitzing/ausweisapp2

Note: The container user has uid 1000, so the Wayland socket path should match ``/run/user/1000/``.


LAN Access
~~~~~~~~~~
To give the container access to your whole LAN (e.g., to connect with your smartphone), use ``--network host``:

::

   podman run --name ausweisapp \
     --network host \
     -e DISPLAY=$DISPLAY -e LANG=$LANG \
     -v /tmp/.X11-unix:/tmp/.X11-unix \
     --privileged aklitzing/ausweisapp2

With ``--network host``, the container shares the host's network stack.
The web interface will be accessible from other LAN devices at ``http://<your-host-ip>:24727``.

Note: ``--network host`` cannot be combined with ``-p`` port mappings.


Card Reader
~~~~~~~~~~~
- **--privileged** is required for *pcscd* to access card reader.
  You could try to bind usb devices to container with ``-v /dev/bus/usb:/dev/bus/usb`` instead.
  Be aware that the usb device must be connected *before* the container is started! This is a limitation by ``-v``.

If you don't have a card reader, you can omit ``--privileged``.


If you are not familiar with Docker. You can add ``-d`` to ``docker run`` to detach from terminal and avoid logging
of AusweisApp. After you created a container and stopped it you can start it with ``docker start ausweisapp`` if
you used the provided name.


Troubleshooting
---------------
- I need a proxy
   - Just add ``-e http_proxy=PROXY:PORT -e https_proxy=PROXY:PORT`` to ``docker run`` cmdline.


- I need AusweisApp in English or German.
   - Change ``-e LANG=$LANG`` to ``-e LANG=de`` or ``-e LANG=en``.


- Window of AusweisApp is black/faulted.
   - Looks like an OpenGL issue. Try to grab the border of the window and resize it.
     Sometimes it will refresh the buffers and repaint the window correctly.


- Container ends immediately
   - Maybe you need to allow local access to your X-Server by ``xhost local:root``.

        | No protocol specified
        | QXcbConnection: Could not connect to display :0
        | Aborted (core dumped)


- Container ends with ``Could not load the Qt platform plugin \"xcb\" in \"\" even though it was found.``
   - Add ``-e QT_DEBUG_PLUGINS=1`` to get more logging of Qt.
   - For Wayland, try setting ``-e QT_QPA_PLATFORM=wayland``.


- My card reader is not recognized
   - The container has ``ccid``, ``pcsc-cyberjack`` and ``acsccid`` drivers installed.
     Try to install another driver by your own and tell me how you did it.
     So I can add it to AlpineLinux and to next docker images. See next bullet point.


- I need to modify the container
   - You can jump into a shell of running container with ``docker exec -ti ausweisapp /bin/sh``
     and modify it by your needs. You can use ``sudo`` as well without a password to get root access.

   - Also you could derive your own Dockerfile from this image by ``FROM aklitzing/ausweisapp2``.


- Is this an official version?
   - NO! You cannot ask Governikus for support!

   - If you don't need a GUI you should try the official Container SDK: https://www.ausweisapp.bund.de/sdk/container.html
