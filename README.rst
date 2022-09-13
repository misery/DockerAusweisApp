.. image:: https://img.shields.io/badge/license-EUPL_v1.2-blue.svg
   :target: https://raw.githubusercontent.com/misery/DockerAusweisApp2/master/LICENSE.txt

.. image:: https://img.shields.io/docker/pulls/aklitzing/ausweisapp2.svg
   :target: https://hub.docker.com/r/aklitzing/ausweisapp2/


AusweisApp2 in Docker (Linux)
=============================
This docker image contains a minimal OS (AlpineLinux) as a base image.

It builds Qt6 and OpenSSL with the cmake library-script of AusweisApp2
and builds AusweisApp2 itself.

Also it contains ``pcscd`` with some additional card reader driver.



Start
-----
You could start AusweisApp2 with this command:

::

   docker run --name ausweisapp -p 127.0.0.1:24727:24727 -e DISPLAY=$DISPLAY -e LANG=$LANG -v /tmp/.X11-unix:/tmp/.X11-unix --privileged aklitzing/ausweisapp2


- **--privileged** is required for *pcscd* to access card reader.
  You could try to bind usb devices to container with ``-v /dev/bus/usb:/dev/bus/usb`` instead.
  Be aware that the usb device must be connected *before* the container is started! This is a limitation by ``-v``.


If you are not familiar with Docker. You can add ``-d`` to ``docker run`` to detach from terminal and avoid logging
of AusweisApp2. After you created a container and stopped it you can start it with ``docker start ausweisapp`` if
you used the provided name.



Troubleshooting
---------------
- I need a proxy
   - Just add ``-e http_proxy=PROXY:PORT -e https_proxy=PROXY:PORT`` to ``docker run`` cmdline.


- I need AusweisApp2 in English or German.
   - Change ``-e LANG=$LANG`` to ``-e LANG=de`` or ``-e LANG=en``.


- Window of AusweisApp2 is black/faulted.
   - Looks like an OpenGL issue. Try to grab the border of the window and resize it.
     Sometimes it will refresh the buffers and repaint the window correctly.


- Container ends immediately
   - Maybe you need to allow local access to your X-Server by ``xhost local:root``.

        | No protocol specified
        | QXcbConnection: Could not connect to display :0
        | Aborted (core dumped)


- Container ends with ``Could not load the Qt platform plugin "xcb" in "" even though it was found.``
   - Add ``-e QT_DEBUG_PLUGINS=1`` to get more logging of Qt.


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

