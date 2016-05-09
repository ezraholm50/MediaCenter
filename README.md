# MediaCenter

* Tested on Ubuntu Core 16.04, server should work and desktop aswell. (Possibly works on lower versions aswell)
* Might work on other debian distro's aswell.

# How to:

* ```sudo mkdir -p /var/scripts```
* ```sudo wget https://github.com/ezraholm50/MultiInstaller/raw/master/MultiInstaller.sh```
* ```sudo bash /var/scripts/MultiInstaller.sh```

# This script can:
* Install Rsync, Webmin, SSH
* Install ClamAV and set daily scans and move infected files to /infected
* Install Fail2Ban (Working on creating jails, need help)
* Install and open [Atomic Toolkit](https://github.com/htpcBeginner/AtoMiC-ToolKit)
* Install Plex (also installs a public auto update script, for plexpass users an option will be added soon)
* Install Nginx, Teamspeak, NFS-client, NFS-server, DDCLIENT (domain DynDns), Letsencrypt (valid SSL cert.) 
* Install other various packages, see the MultiInstaller.sh script for details.
* Let you enable/disable the firewall and allow/deny ports: 10000, 22, 9090, 8989, 8181, 5050, 32400, 8822 and more
* Set swappiness to 1
* Set a static IP in the machine (router needs to be done aswell)
* Set dns to Comodo secure dns
* Much more!

# To do

* Have the option to install ownCloud @enoch85
* Samba
* Backups
* OpenVpn
* Post requests [HERE](https://github.com/ezraholm50/MultiInstaller/issues/1)


* CAREFULL THIS IS ALPHA SOFTWARE, USE AT YOUR OWN RISK

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
