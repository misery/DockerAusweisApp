AusweisApp2 in Docker (Linux)
=============================
This docker image contains a minimal OS (AlpineLinux) as a base image.

It builds Qt5 and OpenSSL with the cmake library-script of AusweisApp2
and builds AusweisApp2 itself.

Also it contains ``pcscd`` with some additional card reader driver.



Start
-----
You could start AusweisApp2 with this command:

::

   docker run --name ausweisapp -e DISPLAY=$DISPLAY -e LANG=$LANG -v /tmp/.X11-unix:/tmp/.X11-unix --privileged --net=host aklitzing/ausweisapp2


- **--privileged** is required for pcscd to access card reader.
  You could try to bind usb devices to container with ``-v /dev/bus/usb:/dev/bus/usb`` instead.
  Be aware that the usb device must be connected *before* the container is started! This is a limitation by ``-v``.

- **--net=host** is required to let the container bind to localhost of docker host system.
  This could be patched later to let AusweisApp2 unbind from localhost and add ``-p 127.0.0.1:24727:24727`` to container.
  This is necessary to allow localhost links in browser to start eID activation.


If you are not familiar with Docker. You can add ``-d`` to ``docker run`` to detach from terminal and avoid logging
of AusweisApp2. After you created a container and stopped it you can start it with ``docker start ausweisapp`` if
you used the provided name.



Troubleshooting
---------------
- I need a proxy
   - Just add ``-e http_proxy=PROXY:PORT -e https_proxy=PROXY:PORT`` to docker run cmdline.

- I need AusweisApp2 in English or German.
   - Change ``-e LANG=$LANG`` to ``-e LANG=de`` or ``-e LANG=en``.

- Window of AusweisApp2 is black/faulted.
   - Looks like an OpenGL issue. Try to grab the border of the window an resize it.
     Sometimes it will refresh the buffers and repaint the window correctly.

- Container ends immediately
   - Maybe you need to allow local access to your X-Server by ``xhost local:root``.

- My card reader is not recognized
   - The container has ``ccid`` and ``pcsc-cyberjack`` drivers installed.
     Try to install another driver by your own and tell me how you did it.
     So I can add it to AlpineLinux and to next docker images. See next bullet point.

- I need to modify container
   - You can jump into a shell of running container with ``docker exec -ti ausweisapp /bin/sh``
     and modify it by your needs. You can use ``sudo`` as well without a password to get root access.

- Is this an official version?
   - NO! You cannot ask Governikus for support!

