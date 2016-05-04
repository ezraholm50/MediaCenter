#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
IFCONFIG="/sbin/ifconfig"
IP="/sbin/ip"
IFACE=$($IP -o link show | awk '{print $2,$9}' | grep "UP" | cut -d ":" -f 1)
INTERFACES="/etc/network/interfaces"
ADDRESS=$($IP route get 1 | awk '{print $NF;exit}')
NETMASK=$($IFCONFIG $IFACE | grep Mask | sed s/^.*Mask://)
GATEWAY=$($IP route | awk '/default/ { print $3 }')
SCRIPTS="/var/scripts"
REPO="https://github.com/ezraholm50/MediaCenter"
COUNTRY="nl" # use your own 2 letter country code for best speeds of the ubuntu/other repo's in sources.list

# Check if root
        if [ "$(whoami)" != "root" ]; then
        echo
        echo -e "\e[31mSorry, you are not root.\n\e[0mYou must type: \e[36msudo \e[0mbash /var/scripts/setup.sh"
        echo
        exit 1
fi

# Set swappiness to 1
echo "vm.swappiness = 1" >> /etc/sysctl.conf
sysctl vm.swappiness=1

# Use Comodo secure dns
echo "nameserver 8.26.56.26" >> /etc/resolvconf/resolv.conf.d/base
echo "nameserver 8.20.247.20" >> /etc/resolvconf/resolv.conf.d/base
resolvconf -u

# Update and upgrade and install many packages
apt-get update && apt-get upgrade -y && apt-get -f install -y
apt-get install openssh-server nano rsync sudo dialog linux-firmware wget clamav fail2ban -y
apt-get install --no-install-recommends network-manager -y

# Change to home country repo
sed -i "s|gb|$COUNTRY|g" /etc/apt/sources.list

# Make scripts dir
mkdir -p $SCRIPTS

# Static ip
wget https://raw.githubusercontent.com/enoch85/ownCloud-VM/master/static/test_connection.sh -P $SCRIPTS
echo -e "\e[0m"
echo "The script will now configure your IP to be static."
echo -e "\e[36m"
echo -e "\e[1m"
echo "Your internal IP is: $ADDRESS"
echo -e "\e[0m"
echo -e "Write this down, you will need it to set static IP"
echo -e "\e[32m"
read -p "Press any key to set static IP..." -n1 -s
clear
echo -e "\e[0m"
ifdown $IFACE
sleep 2
ifup $IFACE
sleep 2

cat <<-IPCONFIG > "$INTERFACES"
        auto lo $IFACE
        iface lo inet loopback
        iface $IFACE inet static
                address $ADDRESS
                netmask $NETMASK
                gateway $GATEWAY
# Exit and save:	[CTRL+X] + [Y] + [ENTER]
# Exit without saving:	[CTRL+X]
IPCONFIG

ifdown $IFACE
sleep 2
ifup $IFACE
sleep 2
echo
echo "Testing if network is OK..."
sleep 1
echo
bash /var/scripts/test_connection.sh
sleep 2
echo
echo -e "\e[0mIf the output is \e[32mConnected! \o/\e[0m everything is working."
echo -e "\e[0mIf the output is \e[31mNot Connected!\e[0m you should change\nyour settings manually in the next step."
echo -e "\e[32m"
read -p "Press any key to open /etc/network/interfaces..." -n1 -s
echo -e "\e[0m"
nano /etc/network/interfaces
clear &&
echo "Testing if network is OK..."
ifdown $IFACE
sleep 2
ifup $IFACE
sleep 2
echo
bash /var/scripts/test_connection.sh
sleep 2
clear

# ClamAv
mkdir -p /infected
chmod -R nobody:nogroup /infected
chown -R 000 /infected
echo "freshclam && clamscan -r --move=/infected / && chown -R nodbody:nogroup /infected && chmod -R 000 /infected " >> /etc/cron.daily/clamscan.sh
chmod 754 /etc/cron.daily/clamscan.sh

# SSH security
sed -i 's|PermitEmptyPasswords yes|PermitEmptyPasswords no|g' /etc/ssh/sshd_config

# Change SSH ports?
# ufw port 8822
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Use port 8822 for SSH?") ]]
then
      ufw allow 8822
      ufw deny 22
      sed -i 's|22|8822|g' /etc/ssh/sshd_config
      echo
      echo "After the reboot you can use port 8822 for SSH"
else
      sleep 1
fi

# webmin
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.791_all.deb -P /tmp/
apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python -y
dpkg --install /tmp/webmin_1.791_all.deb

# Letsencrypt
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Do you want to install a real certificate from Letsencrypt to secure your WAN access to the server.?") ]]
then
	wget $REPO/letsencrypt.sh -P $SCRIPTS/
	wget $REPO/echo_letsencrypt.sh -P $SCRIPTS/
	bash $SCRIPTS/echo_letsencrypt.sh

	function ask_yes_or_no() {
    	read -p "$1 ([y]es or [N]o): "
    	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "no" == $(ask_yes_or_no "Are you sure you want to continue?") ]]
then
	echo
    	echo "OK, but if you want to run this script later, just type: sudo bash /var/scripts/letsencrypt.sh"
    	echo -e "\e[32m"
    	read -p "Press any key to continue... " -n1 -s
    	echo -e "\e[0m"
fi

        function ask_yes_or_no() {
        read -p "$1 ([y]es or [N]o): "
        case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "no" == $(ask_yes_or_no "Have you forwarded port 443 in your router?") ]]
then
        echo
        echo "OK, but if you want to run this script later, just type: sudo bash /var/scripts/letsencrypt.sh"
        echo -e "\e[32m"
        read -p "Press any key to continue... " -n1 -s
        echo -e "\e[0m"
fi

    	function ask_yes_or_no() {
    	read -p "$1 ([y]es or [N]o): "
    	case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
	*)     echo "no" ;;
	esac
}
if [[ "yes" == $(ask_yes_or_no "Do you have a domian that you will use?") ]]
then
        sleep 1
else
	echo
    	echo "OK, but if you want to run this script later, just type: sudo bash /var/scripts/letsencrypt.sh"
    	echo -e "\e[32m"
    	read -p "Press any key to continue... " -n1 -s
    	echo -e "\e[0m"
fi

# Install git
	git --version 2>&1 >/dev/null
	GIT_IS_AVAILABLE=$?
# ...
	if [ $GIT_IS_AVAILABLE -eq 1 ]; then
        sleep 1
else
        apt-get install git -y -q
fi

	cd /var
	git clone https://github.com/letsencrypt/letsencrypt
	cd letsencrypt
	./letsencrypt-auto certonly --agree-tos
	cd
else
	echo
    	echo "OK, but if you want to run this script later, just type: sudo bash /var/scripts/letsencrypt.sh"
    	echo -e "\e[32m"
    	read -p "Press any key to continue... " -n1 -s
    	echo -e "\e[0m"
    	wget $REPO/letsencrypt.sh -P $SCRIPTS/
fi

# DynDns
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Do you have a DynDns service purchased at DynDns.com or Easydns etc?") ]]
then
	echo
    	echo "If the script asks for a network device fill in this: $IFACE"
    	echo -e "\e[32m"
    	read -p "Press any key to continue... " -n1 -s
    	echo -e "\e[0m"
	sudo apt-get install ddclient -y
	echo "ddclient" >> /etc/cron.daily/dns-update.sh
	chmod 755 /etc/cron.daily/dns-update.sh
else
sleep 1
fi

# Plex
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Install PLEX Public?") ]]
then
        apt-get install git -y
        wget https://downloads.plex.tv/plex-media-server/0.9.16.6.1993-5089475/plexmediaserver_0.9.16.6.1993-5089475_amd64.deb -P /tmp/
	dpkg -i /tmp/plexmediaserver_0.9.16.6.1993-5089475_amd64.deb
	cd /root
	
if 		[ -d /root/plexupdate ];
then
	rm -r /root/plexupdate
fi

	git clone https://github.com/mrworf/plexupdate.git
	touch /root/.plexupdate
	cat <<-PLEX > "/root/.plexupdate"
	DOWNLOADDIR="/tmp"
	RELEASE="64"
	KEEP=no
	FORCE=no
	PUBLIC=yes
	AUTOINSTALL=yes
	AUTODELETE=yes
	AUTOUPDATE=yes
        AUTOSTART=yes
	PLEX
if 		[ -f /etc/cron.daily/plex.sh ];
then
	sleep 1
else
	echo "bash /root/plexupdate/plexupdate.sh" >> /etc/cron.daily/plex.sh
	chmod 754 /etc/cron.daily/plex.sh
fi

else
      echo
      echo "No plex, ok moving on..."
      echo
fi

# nginx
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Install Nginx?") ]]
then
      apt-get install nginx -y
else
      echo
      echo "No Nginx, ok moving on..."
      echo
fi

# nfs server
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Install NFS Server?") ]]
then
      apt-get install nfs-kernel-server -y
      ufw allow 2049
else
      echo
      echo "No Nfs Server, ok moving on..."
      echo
fi

# nfs client yes no?
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Install NFS Client?") ]]
then
      apt-get install nfs-common -y
      ufw allow 2049
      echo
      echo "mount your share like this: mount -t nfs -o proto=tcp,port=2049 <nfs-server-IP>:/ /mount_point"
      echo "auto mount like this: echo "<nfs-server-IP>:/   /mount_point   nfs    auto  0  0" >> /etc/fstab"
      echo -e "\e[32m"
      read -p "Press any key to continue..." -n1 -s
      echo -e "\e[0m"
else
      echo
      echo "No Nfs Client, ok moving on..."
      echo
fi

# Update and upgrade again
apt-get update && apt-get upgrade -y && apt-get -f install -y
dpkg --configure --pending

# Set ufw ports
ufw allow 22
ufw allow 10000
echo

# ufw port 443 and 80
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Open port 443 and 80?") ]]
then
      ufw allow 443
      ufw allow 80
      echo
else
      sleep 1
      echo
fi

# ufw port 32400
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Open port 32400?") ]]
then
      ufw allow 32400
      echo
else
      sleep 1
      echo
fi

# ufw port 9090
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Open port 9090?") ]]
then
      ufw allow 9090
      echo
else
      sleep 1
      echo
fi

# ufw port 8989
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Open port 8989?") ]]
then
      ufw allow 8989
      echo
else
      sleep 1
      echo
fi

# ufw port 5050
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Open port 5050?") ]]
then
      ufw allow 5050
      echo
else
      sleep 1
      echo
fi

# ufw port 8181
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Open port 8181?") ]]
then
      ufw allow 8181
      echo
else
      sleep 1
      echo
fi

# ufw port 8085
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Open port 8085?") ]]
then
      ufw allow 8085
      echo
else
      sleep 1
      echo
fi

# ufw
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Enable UFW?") ]]
then
      ufw enable
      echo
else
      sleep 1
      echo
fi

# Install AtoMiC ToolKit
echo
echo -e "\e[0mNext you will be promted a tool to install packages like Sonarr, Couchpotato, SABNZBD and Headphones."
echo -e "\e[0mNote that Webmin and Plex are already installed. You can re-run the setup by typing: sudo bash /root/AtoMiC-ToolKit/setup.sh"
echo -e "\e[32m"
read -p "Press any key to begin..." -n1 -s
echo -e "\e[0m"
echo

apt-get -y install git-core
git clone https://github.com/htpcBeginner/AtoMiC-ToolKit ~/AtoMiC-ToolKit
cd ~/AtoMiC-ToolKit
sudo bash setup.sh
cd

# Teamspeak
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Do you want to install Teamspeak?") ]]
then
# Add user
useradd teamspeak3
sed -i 's|:/home/teamspeak3:|:/home/teamspeak3:/usr/sbin/nologin|g' /etc/passwd

# Get Teamspeak
wget http://ftp.4players.de/pub/hosted/ts3/releases/3.0.10.3/teamspeak3-server_linux-amd64-3.0.10.3.tar.gz -P /tmp

# Unpack Teamspeak
tar xzf /tmp/teamspeak3-server_linux-amd64-3.0.10.3.tar.gz

# Move to right directory
mv /tmp/teamspeak3-server_linux-amd64 /usr/local/teamspeak3

# Set ownership
chown -R teamspeak3 /usr/local/teamspeak3

# Add to upstart
ln -s /usr/local/teamspeak3/ts3server_startscript.sh /etc/init.d/teamspeak3
update-rc.d teamspeak3 defaults

# Warning
echo -e "\e[32m"
echo    "+--------------------------------------------------------------------+"
echo    "| Next you will need to copy/paste 3 things to a safe location       |"
echo    "|                                                                    |"
echo -e "|         \e[0mLOGIN, PASSWORD, SECURITY TOKEN\e[32m                            |"
echo    "|                                                                    |"
echo -e "|         \e[0mIF YOU FAIL TO DO SO, YOU HAVE TO REINSTALL YOUR SYSTEM\e[32m    |"
echo -e "|         \e[0mIn 30 Sec the script will continue, so be quick!/e[32m           |"
echo    "+--------------------------------------------------------------------+"
echo
read -p "Press any key to start copying the important stuff to a safe location..." -n1 -s
echo -e "\e[0m"
echo

# Start service
service teamspeak3 start && sleep 30
echo
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Did you copy all the details?") ]]
then
	sleep 1
	echo
else
      sleep 30
      echo "I will give you another 30 seconds, please hurry!"
      echo
fi

# Update and upgrade again
apt-get autoremove -y && apt-get autoclean && apt-get update && apt-get upgrade -y && apt-get -f install -y
dpkg --configure --pending


# Show access details
	cat << STARTMSG
+---------------------------------------------------------------+
|       You are done now, thank you for using this script!      |
|       Please visit https://www.techandme.se                   |
|       For more awsome guides, news and virtual machines       |
|       It's free of charge, and very easy to use.              |
|                                                               |
|       System reboot required (notice the SSH port, if changed)|
+---------------------------------------------------------------+

STARTMSG

echo
echo -e "\e[32m"
read -p "Press any key to reboot... or ctrl+c to cancel the reboot" -n1 -s
echo -e "\e[0m"
echo
reboot

exit
