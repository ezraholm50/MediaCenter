# MediaCenter

* Tested on Ubuntu Core 16.04, server should work and desktop aswell. (Possibly works on lower versions aswell)

# How to:

* ```sudo wget https://github.com/ezraholm50/MediaCenter/raw/master/setup.sh```
* ```sudo bash setup.sh```

# This script will:
* Install Webmin
* Install SSH-server
* Install Rsync
* Install Nano
* Install ClamAV and set daily scans and move infected files to /infected
* Install Fail2Ban (Working on creating jails, need help)
* Install and open [Atomic Toolkit](https://github.com/htpcBeginner/AtoMiC-ToolKit)
* Install other various packages, see the setup.sh script for details.
* UFW allow 10000, 22 and ask if you want to enable it and open 9090, 8989, 8181, 5050, 32400, 8822 (SSH, it also changes your ssh port and deny's 22)
* Ask if you want to install Plex, Nginx, Teamspeak, NFS-client, NFS-server, DDCLIENT (domain DynDns), Letsencrypt (valid SSL cert.) 
* Set swappiness to 1
* Set a static IP in the machine (router needs to be done aswell)
* Set dns to Comodo secure dns

# To do

* Have the option to install ownCloud @enoch85
* Samba
* Backups
* Post requests [HERE](https://github.com/ezraholm50/MediaCenter/issues/1)

# Tech and Me

We at [Tech and Me](https://www.techandme.se) dedicate our time building and maintaining Virtual Machines so that the less skilled users can benefit from easy setup servers.

Here is an example of VM's we offer for **free**:

* ownCloud
* ownCloud on a RaspberryPI
* WordPress
* Minecraft
* Access manager
* TeamSpeak

Its as easy as downloading the virtual disk image, mounting it and use it!

For great guides on Linux, ownCloud and Virtual Machines visit [Tech and Me](https://www.techandme.se)
