#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
# Var's
IFCONFIG="/sbin/ifconfig"
IP="/sbin/ip"
IFACE=$($IP -o link show | awk '{print $2,$9}' | grep "UP" | cut -d ":" -f 1)
INTERFACES="/etc/network/interfaces"
ADDRESS=$($IP route get 1 | awk '{print $NF;exit}')
NETMASK=$($IFCONFIG $IFACE | grep Mask | sed s/^.*Mask://)
GATEWAY=$($IP route | awk '/default/ { print $3 }')
SCRIPTS="/var/scripts"

# Check if root
        if [ "$(whoami)" != "root" ]; then
        echo
        echo -e "\e[31mSorry, you are not root.\n\e[0mYou must type: \e[36msudo \e[0mbash /var/scripts/setup.sh"
        echo
        exit 1
fi

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

# Update and upgrade and install many packages
apt-get update && apt-get upgrade -y && apt-get -f install -y
apt-get install openssh-server nano sudo dialog linux-firmware clamav fail2ban systemd rsyslog

# ClamAv
mkdir /infected
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
exit 0

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
        wget https://downloads.plex.tv/plex-media-server/0.9.16.6.1993-5089475/plexmediaserver_0.9.16.6.1993-5089475_amd64.deb -P /tmp/
dpkg -i /tmp/0.9.16.6.1993-5089475/plexmediaserver_0.9.16.6.1993-5089475_amd64.deb
cd /root
git clone https://github.com/mrworf/plexupdate.git
touch /root/.plexupdate
cat <<-SOURCES > "/root/.plexupdate"
DOWNLOADDIR="/tmp"
RELEASE="64"
KEEP=no
FORCE=no
PUBLIC=yes
AUTOINSTALL=yes
AUTODELETE=yes
AUTOUPDATE=yes
        AUTOSTART=yes

else
      echo
      echo "No plex, ok moving on..."
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
else
      echo
      echo "No Nfs Server, ok moving on..."
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
else
      echo
      echo "No Nfs Client, ok moving on..."
fi

# Update and upgrade again
apt-get update && apt-get upgrade -y && apt-get -f install -y
dpkg --configure --pending

# Set ufw ports
ufw allow 22
ufw allow 10000

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
else
      sleep 1
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
else
      sleep 1
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
else
      sleep 1
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
else
      sleep 1
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
else
      sleep 1
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
else
      sleep 1
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
else
      sleep 1
fi

# ufw port 2049
function ask_yes_or_no() {
    read -p "$1 ([y]es or [N]o): "
    case $(echo $REPLY | tr '[A-Z]' '[a-z]') in
        y|yes) echo "yes" ;;
        *)     echo "no" ;;
    esac
}
if [[ "yes" == $(ask_yes_or_no "Open port 2049, NFS?") ]]
then
      ufw allow 2049
else
      sleep 1
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
else
      sleep 1
fi

# Install AtoMiC ToolKit
echo
echo -e "\e[0mNext you will be promted a tool to install packages like Sonarr, Couchpotato, SABNZBD and Headphones."
echo -e "\e[0mNote that Webmin and Plex are already installed. You can re-run the setup by typing: sudo bash /root/AtoMiC-ToolKit/setup.sh"
echo -e "\e[32m"
read -p "Press any key to begin..." -n1 -s
echo -e "\e[0m"

apt-get -y install git-core
git clone https://github.com/htpcBeginner/AtoMiC-ToolKit ~/AtoMiC-ToolKit
cd ~/AtoMiC-ToolKit
sudo bash setup.sh
cd
