#!/bin/sh
#
# Tech and Me, 2016 - www.techandme.se
#
# See LICENSE file for copyright and license details
#########################################Var's########################################################
IFCONFIG=$(ifconfig)
IP="/sbin/ip"
IFACE=$($IP -o link show | awk '{print $2,$9}' | grep "UP" | cut -d ":" -f 1)
INTERFACES="/etc/network/interfaces"
ADDRESS=$($IP route get 1 | awk '{print $NF;exit}')
NETMASK=$(ifconfig $IFACE | grep Mask | sed s/^.*Mask://)
GATEWAY=$($IP route | awk '/default/ { print $3 }')
SCRIPTS="/var/scripts"
REPO="https://github.com/ezraholm50/MultiInstaller/raw/master"
INTERACTIVE=True
DIR='/etc/update-motd.d'
ASK_TO_REBOOT=0
WHOAMI=$(whoami)
mkdir -p $SCRIPTS
#########################################Root check########################################################
# Check if root
if [ "$(whoami)" != "root" ]; then
        whiptail --msgbox "Sorry you are not root. You must type: sudo bash /var/scripts/MultiInstaller.sh" 20 60 1
        exit
fi
#########################################Whiptail check########################################################
	if [ $(dpkg-query -W -f='${Status}' whiptail 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
        sleep 0

else
	apt-get install whiptail -y
fi
#########################################Update########################################################
# Run apt-get update, saves time. Instead of for every install running apt-get update
    {
    i=1
    while read -r line; do
        i=$(( $i + 1 ))
        echo $i
    done < <(apt-get update)
    } | whiptail --title "Progress" --gauge "Please wait while updating repo's" 6 60 0
#########################################Screen size########################################################
calc_wt_size() {
  # NOTE: it's tempting to redirect stderr to /dev/null, so supress error 
  # output from tput. However in this case, tput detects neither stdout or 
  # stderr is a tty and so only gives default 80, 24 values
  WT_HEIGHT=17
  WT_WIDTH=$(tput cols)

  if [ -z "$WT_WIDTH" ] || [ "$WT_WIDTH" -lt 60 ]; then
    WT_WIDTH=80
  fi
  if [ "$WT_WIDTH" -gt 178 ]; then
    WT_WIDTH=120
  fi
  WT_MENU_HEIGHT=$(($WT_HEIGHT-7))
}
#########################################About########################################################
do_about() {
  whiptail --msgbox "\
This tool is created by techandme.se for less skilled linux terminal users.
It makes your life very easy by just browsing the menu and installing or setting 
config value's to your needs. Please post requests or suggestions here:
https://github.com/ezraholm50/MediaCenter/issues/1
Please visit https://www.techandme.se for awsome free virtual machines,
ownCloud, Teamspeak, Wordpress etc.\
" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}
#########################################tools menu########################################################
do_tools() {
  FUN=$(whiptail --title "Multi Installer - https://www.techandme.se" --menu "System tools" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT \
    "T1 Show LAN IP, Gateway, Netmask" "Ifconfig" \
    "T2 Show WAN IP" "External IP address" \
    "T3 Change Hostname" "Change your network name" \
    "T4 Internationalisation Options" "Change language, time, date and keyboard layout" \
    "T5 Do distribution upgrade" "Tested on ubuntu, debian might work" \
    "T6 Change current users password" "Current user = $WHOAMI" \
    "T7 Set swappiness to 1" "Avoid swapping when there's much RAM left" \
    "T8 Set DNS" "We will use Comodo secure DNS" \
    "T9 Change Repo's" "under construction" \
    "T10 Set static IP" "DOES NOT WORK, BREAKS CONNECTION, WILL BE FIXED" \
    "T11 Blkid" "Show connected devices" \
    "T12 Df -h" "Show disk space" \
    "T13 Connect to WLAN" "Wifi" \
    "T14 Boot to terminal by default" "Only if you use a GUI/desktop now" \
    "T15 Boot to GUI/desktop by default" "Only if you have a GUI installed" \
    "T16 Show System info" "Package Landscape-common needs to be installed" \
    "T17 Add progress bar" "To apt / apt-get update/install/upgrade" \
    "T18 Current users" "Show current users logged in" \
    "T19 Backup with rsync" "Lets you choose dir/file and dest" \
    "T20 List directory" "Files and permissions" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      T1\ *) do_ifconfig ;;
      T2\ *) do_wan_ip ;;
      T3\ *) do_change_hostname ;;
      T4\ *) do_internationalisation_menu ;;
      T5\ *) do_dist_upgrade ;;
      T6\ *) do_change_pass ;;
      T7\ *) do_swappiness;;
      T8\ *) do_comodo_dns ;;
      T9\ *) do_country_repo ;;
      T10\ *) do_static_ip ;;
      T11\ *) do_blkid ;;
      T12\ *) do_df ;;
      T13\ *) do_wlan ;;
      T14\ *) do_boot_text ;;
      T15\ *) do_boot_gui ;;
      T16\ *) do_landscape ;;
      T17\ *) do_fancy ;;
      T18\ *) do_currentusers ;;
      T19\ *) do_backup ;;
      T20\ *) do_listdir ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
}
#########################################tools menu########################################################
do_listdir() {
	LISTDIR=$(whiptail --title "Directory to list? Eg. /mnt/yourfolder" --inputbox "Navigate with TAB to hit ok to enter input" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT 3>&1 1>&2 2>&3)
	whiptail --msgbox "ls -la $LISTDIR" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
	
}
######Tools variable's#######
do_backup() {
	BACKUPDIR=$(whiptail --title "Backup directory? Eg. /mnt/yourfolder" --inputbox "Navigate with TAB to hit ok to enter input" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT 3>&1 1>&2 2>&3)
	BACKUPDEST=$(whiptail --title "Backup destination? Eg. /mnt/yourfolder" --inputbox "Navigate with TAB to hit ok to enter input" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT 3>&1 1>&2 2>&3)
	if [ $(dpkg-query -W -f='${Status}' rsync 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
        echo "Rsync is already installed!"

else
	apt-get install rsync -y
fi
	rsync -aAXv $BACKUPDIR $BACKUPDEST
}
######Tools variable's#######
do_currentusers() {
   	USERLIST=$(userlist)
   	if [ $(dpkg-query -W -f='${Status}' cfingerd 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
        echo "Cfingerd is already installed!"

else
	apt-get install cfingerd -y
fi
   	whiptail --msgbox "$USERLIST" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}
######Tools variable's#######
do_landscape() {
	SYSINFO=$($DIR/50-landscape-sysinfo)
	HEADER=$($DIR/00-header)
	UPDATES=$($DIR/90-updates-available)
	RELEASE=$($DIR/91-release-upgrade)
	FSCK=$($DIR/98-fsck-at-reboot)
	REBOOT=$($DIR/98-reboot-required)
	whiptail --msgbox "\
$HEADER
$SYSINFO
$UPDATES
$RELEASE
$FSCK
$REBOOT\
" 40 80
}
######Tools variable's#######
do_fancy() {
	echo "Dpkg::Progress-Fancy "1";" > /etc/apt/apt.conf.d/99progressbar
	whiptail --msgbox "You now have a fancy progress bar in green, outside this installer run apt or apt-get install <package>" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}
######Tools variable's#######
do_boot_text() {
	sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT=""|GRUB_CMDLINE_LINUX_DEFAULT="text"|g' /etc/default/grub
	update-grub
}
######Tools variable's#######
do_boot_gui() {
	sed -i 's|GRUB_CMDLINE_LINUX_DEFAULT="text"|GRUB_CMDLINE_LINUX_DEFAULT=""|g' /etc/default/grub
	update-grub	
}
######Tools variable's#######
do_wlan() {
	IWLIST=$(iwlist wlan0 scanning|grep -i 'essid')
	whiptail --msgbox "Next you will be shown a list with wireless access points, copy yours.." $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
	whiptail --msgbox "$IWLIST" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
	WLAN=$(whiptail --title "SSID, network name? (case sensetive)" --inputbox "Navigate with TAB to hit ok to enter input" 10 60 3>&1 1>&2 2>&3)
	WLANPASS=$(whiptail --title "Wlan password? (case sensetive)" --passwordbox "Navigate with TAB to hit ok to enter input" 10 60 3>&1 1>&2 2>&3)
	if [ $exitstatus = 0 ]; then
	
	if [ $(dpkg-query -W -f='${Status}' linux-firmware 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
        echo "Linux-firmware is already installed!"

else
	apt-get install linux-firmware -y
fi

	if [ $(dpkg-query -W -f='${Status}' wpasupplicant 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
        echo "Wpasupplicant is already installed!"

else
	apt-get install wpasupplicant -y
fi
	
	ifup wlan0
	iwconfig wlan0 essid $WLAN key s:$WLANPASS
	ifdown wlan0
	ifup wlan0
	dhcpcd -r
	dhcpcd wlan0
	else
    	echo "You chose Cancel."
	fi
}
######Tools variable's#######
do_df() {
  DF=$(df -h)
  whiptail --msgbox "$DF" 20 $WT_WIDTH $WT_MENU_HEIGHT
}
######Tools variable's#######
do_blkid() {
  BLKID=$(blkid)
  whiptail --msgbox "$BLKID" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}
######Tools variable's#######
do_ifconfig() {
whiptail --msgbox "\
Interface:$IFACE
LAN IP: $ADDRESS
Netmask: $NETMASK
Gateway: $GATEWAY\
" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}
######Tools variable's#######
do_wan_ip() {
  WAN=$(wget -qO- http://ipecho.net/plain ; echo)
  whiptail --msgbox "WAN IP: $WAN" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}
######Tools variable's#######
do_change_pass() {
	USERPASS=$(whiptail --title "User to change pass for? (case sensetive)" --inputbox "Navigate with TAB to hit ok to enter input" 10 60)
  	passwd $USERPASS &&
  	whiptail --msgbox "Password changed successfully" 20 60 1
}
######Tools variable's#######
do_internationalisation_menu() {
  FUN=$(whiptail --title "Multi Installer - https://www.techandme.se" --menu "Internationalisation Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
    "I1 Change Locale" "Set up language and regional settings to match your location" \
    "I2 Change Timezone" "Set up timezone to match your location" \
    "I3 Change Keyboard Layout" "Set the keyboard layout to match your keyboard" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      I1\ *) do_change_locale ;;
      I2\ *) do_change_timezone ;;
      I3\ *) do_configure_keyboard ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
}
######Tools variable's#######
do_configure_keyboard() {
  dpkg-reconfigure keyboard-configuration &&
  printf "Reloading keymap. This may take a short while\n" &&
  invoke-rc.d keyboard-setup start
}
######Tools variable's#######
do_change_locale() {
  dpkg-reconfigure locales
}
######Tools variable's#######
do_change_timezone() {
  dpkg-reconfigure tzdata
}
######Tools variable's#######
do_change_hostname() {
  whiptail --msgbox "\
Please note: RFCs mandate that a hostname's labels \
may contain only the ASCII letters 'a' through 'z' (case-insensitive), 
the digits '0' through '9', and the hyphen.
Hostname labels cannot begin or end with a hyphen. 
No other symbols, punctuation characters, or blank spaces are permitted.\
" 20 70 1

  CURRENT_HOSTNAME=`cat /etc/hostname | tr -d " \t\n\r"`
  NEW_HOSTNAME=$(whiptail --inputbox "Please enter a hostname" 20 60 "$CURRENT_HOSTNAME" 3>&1 1>&2 2>&3)
  if [ $? -eq 0 ]; then
    echo $NEW_HOSTNAME > /etc/hostname
    sed -i "s/127.0.1.1.*$CURRENT_HOSTNAME/127.0.1.1\t$NEW_HOSTNAME/g" /etc/hosts
    ASK_TO_REBOOT=1
  fi
}
######Tools variable's#######
do_dist_upgrade() {
	do-release-upgrade -y
}
######Tools variable's#######
do_swappiness() {
	sed -i 's|vm.swappiness = |#vm.swappiness = |g' /etc/sysctl.conf
	echo "vm.swappiness = 1" >> /etc/sysctl.conf
	sysctl vm.swappiness=1
}
######Tools variable's#######
do_comodo_dns() {
	cat /dev/null > /etc/resolvconf/resolv.conf.d/base
	echo "nameserver 8.26.56.26" >> /etc/resolvconf/resolv.conf.d/base
	echo "nameserver 8.20.247.20" >> /etc/resolvconf/resolv.conf.d/base
	resolvconf -u
}
######Tools variable's#######
do_country_repo() {
	SHOWCOUNT=$(cat /etc/apt/sources.list)
	whiptail --msgbox "Notice your current country code (2 letters eg. NL, US)" 20 70
	COUNTRYCUR=$(whiptail --title "What is the current country code? (2 letters eg. NL, US)" --inputbox "Navigate with TAB to hit ok to enter input" 10 60)
	COUNTRY=$(whiptail --title "What is your country code? (2 letters eg. NL, US)" --inputbox "Navigate with TAB to hit ok to enter input" 10 60)
	sed -i "s|$COUNTRYCUR|$COUNTRY|" /etc/apt/sources.list
	apt-get update
}
######Tools variable's#######
do_static_ip() {
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
}
#########################################Firewall menu########################################################
do_firewall() {
  FUN=$(whiptail --title "Multi Installer - https://www.techandme.se" --menu "Firewall options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
    "A1 Enable Firewall" "" \
    "A2 Disable Firewall" "" \
    "A3 Allow port Multiple" "Teamspeak" \
    "A4 Allow port 32400" "Plex" \
    "A5 Allow port 8989" "Sonarr" \
    "A6 Allow port 5050" "Couchpotato" \
    "A7 Allow port 8181" "Headphones" \
    "A8 Allow port 8085" "HTPC Manager" \
    "A9 Allow port 8080" "Mylar" \
    "A10 Allow port 10000" "Webmin" \
    "A11 Allow port 8080" "Sabnzbdplus" \
    "A12 Allow port 9090" "Sabnzbdplus https" \
    "A13 Allow port 2049" "NFS" \
    "A14 Deny port Multiple" "Teamspeak" \
    "A15 Deny port 32400" "Plex" \
    "A16 Deny port 8989" "Sonarr" \
    "A17 Deny port 5050" "Couchpotato" \
    "A18 Deny port 8181" "Headphones" \
    "A19 Deny port 8085" "HTPC Manager" \
    "A20 Deny port 8080" "Mylar" \
    "A21 Deny port 10000" "Webmin" \
    "A22 Deny port 8080" "Sabnzbdplus" \
    "A23 Deny port 9090" "Sabnzbdplus https" \
    "A24 Deny port 2049" "NFS" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      A1\ *) do_ufw_enable ;;
      A2\ *) do_ufw_disable ;;
      A3\ *) do_allow_teamspeak ;;
      A4\ *) do_allow_32400 ;;
      A5\ *) do_allow_8989 ;;
      A6\ *) do_allow_5050 ;;
      A7\ *) do_allow_8181 ;;
      A8\ *) do_allow_8085 ;;
      A9\ *) do_allow_mylar ;;
      A10\ *) do_allow_10000 ;;
      A11\ *) do_allow_8080 ;;
      A12\ *) do_allow_9090 ;;
      A13\ *) do_allow_2049 ;;
      A14\ *) do_deny_teamspeak ;;
      A15\ *) do_deny_32400 ;;
      A16\ *) do_deny_8989 ;;
      A17\ *) do_deny_5050 ;;
      A18\ *) do_deny_8181 ;;
      A19\ *) do_deny_8085 ;;
      A20\ *) do_deny_mylar ;;
      A21\ *) do_deny_10000 ;;
      A22\ *) do_deny_8080 ;;
      A23\ *) do_deny_9090 ;;
      A24\ *) do_deny_2049 ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
}
#########################################Firewall menu########################################################

######Firewall variable's#######
do_ufw_enable() {
sudo ufw enable
}
######Firewall variable's#######
do_ufw_disable() {
sudo ufw disable
}
######Firewall variable's#######
do_allow_32400() {
sudo ufw allow 32400
}
######Firewall variable's#######
do_allow_10000() {
sudo ufw allow 10000
}
######Firewall variable's#######
do_allow_5050() {
sudo ufw allow 5050
}
######Firewall variable's#######
do_allow_9090() {
sudo ufw allow 9090
}
######Firewall variable's#######
do_allow_8080() {
sudo ufw allow 8080
}
######Firewall variable's#######
do_allow_8989() {
sudo ufw allow 8989
}
######Firewall variable's#######
do_allow_8181() {
sudo ufw allow 8181
}
######Firewall variable's#######
do_allow_8085() {
sudo ufw allow 8085
}
######Firewall variable's#######
do_allow_mylar() {
sudo ufw allow 8080
}
######Firewall variable's#######
do_allow_2049() {
sudo ufw allow 2049
}
######Firewall variable's#######
do_allow_teamspeak() {
sudo ufw allow 9987
sudo ufw allow 10011
sudo ufw allow 30033
}
######Firewall variable's#######
do_deny_32400() {
sudo ufw deny 32400
}
######Firewall variable's#######
do_deny_10000() {
sudo ufw deny 10000
}
######Firewall variable's#######
do_deny_5050() {
sudo ufw deny 5050
}
######Firewall variable's#######
do_deny_9090() {
sudo ufw deny 9090
}
######Firewall variable's#######
do_deny_8080() {
sudo ufw deny 8080
}
######Firewall variable's#######
do_deny_8989() {
sudo ufw deny 8989
}
######Firewall variable's#######
do_deny_8181() {
sudo ufw deny 8181
}
######Firewall variable's#######
do_deny_8085() {
sudo ufw deny 8085
}
######Firewall variable's#######
do_deny_mylar() {
sudo ufw deny 8080
}
######Firewall variable's#######
do_deny_2049() {
sudo ufw deny 2049
}
######Firewall variable's#######
do_deny_teamspeak() {
sudo ufw deny 9987
sudo ufw deny 10011
sudo ufw deny 30033
}
#########################################Upgrade and update system and tool########################################################
do_update_full() {
  apt-get autoclean -y
  apt-get autoremove -y
  apt-get update
  apt-get upgrade -y
  apt-get -f install -y
  dpkg --configure --pending
  rm $SCRIPTS/MultiInstaller.sh  
  mkdir -p $SCRIPTS 
  wget $REPO/MultiInstaller.sh -P $SCRIPTS/
  printf "Sleeping 5 seconds before reloading the Multi Installer\n"
  sleep 5
  bash $SCRIPTS/MultiInstaller.sh
}
#########################################Finish and reboot?########################################################
do_finish() {
  if [ $ASK_TO_REBOOT -eq 1 ]; then
    whiptail --yesno "Would you like to reboot now?" 20 60 2
    if [ $? -eq 0 ]; then # yes
      sync
      reboot
    fi
  fi
  exit 0
}
#########################################Install menu########################################################
do_install_menu() {
  FUN=$(whiptail --title "Multi Installer - https://www.techandme.se" --menu "Package list" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
    "I1 Install Package" "User defined" \
    "I2 Install Webmin" "Graphical interface to manage headless systems" \
    "I3 Install SSH Server" "Needed by a remote machine to be accessable via SSH" \
    "I4 Install SSH Client" "Needed by the local machine to connect to a remote machine" \
    "I5 Change SSH-server port" "Change SSH-server port to 8822" \
    "I6 Install ClamAV" "Antivirus, set daily scans, infected will be moved to /infected" \
    "I7 Install Fail2Ban" "Install a failed login monitor, needs jails for apps!!!!" \
    "I8 Install Nginx" "Install Nginx webserver" \
    "I9 Install Teamspeak" "Install Teamspeak 3 server to do voice chat" \
    "I10 Install NFS Client" "Install NFS client to be able to mount NFS shares" \
    "I11 Install NFS Server" "Install NFS server to be able to broadcast NFS shares" \
    "I12 Install DDClient" "Update Dynamic Dns with WAN IP, dyndns.com, easydns.com etc." \
    "I13 Install Letsencrypt" "Install free valid SSL certificates with your domain name" \
    "I14 Install Rsync" "Install a sync package to backup/copy filesystems/folders/files" \
    "I15 Install Samba" "Under construction" \
    "I16 Install Landscape-common" "System monitoring" \
    "I17 Install Htop" "Graphical tool to see current mem usage/cpu etc." \
    "I18 Install Network manager" "Advanced network tools" \
    "I19 Install ownCloud" "Your own Dropbox/google drive" \
    "I20 Install OpenVpn" "Connect to a VPN server" \
    "I21 Install Plex" "Media server, Public release no plexpass. Auto updates are set." \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      I1\ *) do_install_package ;;
      I2\ *) do_install_webmin ;;
      I3\ *) do_install_SSH_server ;;
      I4\ *) do_install_SSH_client ;;
      I5\ *) do_ssh ;;
      I6\ *) do_clamav ;;
      I7\ *) do_fail2ban ;;
      I8\ *) do_nginx ;;
      I9\ *) do_teamspeak ;;
      I10\ *) do_install_nfs_client ;;
      I11\ *) do_install_nfs_server ;;
      I12\ *) do_install_ddclient ;;
      I13\ *) do_install_letsencrypt ;;
      I14\ *) do_install_rsync ;;
      I15\ *) do_install_samba ;;
      I16\ *) do_install_landscape ;;
      I17\ *) do_install_htop ;;
      I18\ *) do_install_networkmanager ;;
      I19\ *) do_install_owncloud ;;
      I20\ *) do_install_openvpn ;;
      I21\ *) do_install_plex ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
}
#########################################Install menu########################################################
do_install_package() {
	PACKAGE=$(whiptail --title "Package name?" --inputbox "Navigate with TAB to hit ok to enter input" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT)
	
	if [ $(dpkg-query -W -f='${Status}' $PACKAGE 2>/dev/null | grep -c "ok installed") -eq 1 ];
then
        echo "$PACKAGE is already installed!"

else
	apt-get install $PACKAGE -y
fi
}
########Install variable's########
do_install_openvpn() {
	apt-get install openvpn -y
}
########Install variable's########
do_install_owncloud() {
	apt-get install libreoffice -y
	wget https://github.com/enoch85/ownCloud-VM/raw/master/production/owncloud_install_production.sh -P /var/scripts/
	bash /var/scripts/owncloud_install_production.sh
	#whiptail --msgbox "We will now reboot and start the ownCloud installation" 20 60 1
	reboot
}
########Install variable's########
do_install_networkmanager() {
	apt-get install network-manager -y
}
########Install variable's########
do_install_landscape() {
	apt-get install landscape-common -y
}
########Install variable's########
do_install_htop() {
	apt-get install htop -y
}
########Install variable's########
do_install_samba() {
	apt-get install samba smbfs -y
	sed -i 's|;  security = user|security = user|g' /etc/samba/smb.conf
	echo "username map = /etc/samba/smbusers" > /etc/samba/smb.conf
	USRS=$(whiptail --title "Samba username, create one please" --inputbox "Navigate with TAB to hit ok to enter input" 10 60 3>&1 1>&2 2>&3)
	USRU=$(whiptail --title "Ubuntu username? Should not be root!" --inputbox "Navigate with TAB to hit ok to enter input" 10 60 3>&1 1>&2 2>&3)
	exitstatus=$?
	if [ $exitstatus = 0 ]; then
    	echo "$USRU = '$USRS'" > /tmp/smbusers
	else
    	echo "You chose Cancel."
	fi

	PASSWORD=$(whiptail --title "Samba user password" --passwordbox "Navigate with TAB to hit ok to enter input" 10 60 3>&1 1>&2 2>&3)
 	exitstatus=$?
	if [ $exitstatus = 0 ]; then
     	smbpasswd -a  $USRS
	$PASSWORD
	else	
    	echo "You chose Cancel."
	fi
}
########Install variable's########
do_install_plex() {
  apt-get install wget git -y
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
}
########Install variable's########
do_install_webmin() {
  	wget http://prdownloads.sourceforge.net/webadmin/webmin_1.791_all.deb -P /tmp/
  	apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python -y
  	dpkg --install /tmp/webmin_1.791_all.deb
}
########Install variable's########
do_install_SSH_server() {
	apt-get install openssh-server -y
  	sed -i 's|PermitEmptyPasswords yes|PermitEmptyPasswords no|g' /etc/ssh/sshd_config
}
########Install variable's########
do_install_SSH_client() {
  	apt-get install openssh-client -y
}
########Install variable's########
do_ssh() {
  	ufw allow 8822
  	ufw deny 22
  	sed -i 's|22|8822|g' /etc/ssh/sshd_config
  	echo
  	echo "After the reboot you can use port 8822 for SSH"
}
########Install variable's########
do_clamav() {
  	apt-get install clamav -y
  	mkdir -p /infected
  	chmod -R nobody:nogroup /infected
  	chown -R 000 /infected
  	echo "freshclam && clamscan -r --move=/infected / && chown -R nodbody:nogroup /infected && chmod -R 000 /infected " >> /etc/cron.daily/clamscan.sh
  	chmod 754 /etc/cron.daily/clamscan.sh
}
########Install variable's########
do_fail2ban() {
  	apt-get install fail2ban -y
}
########Install variable's########
do_nginx() {
  	apt-get install nginx -y
  	ufw allow 443
  	ufw allow 80
}
########Install variable's########
do_teamspeak() {
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
}
########Install variable's########
do_install_nfs_client() {
	apt-get install nfs-common -y
  	ufw allow 2049 
  	whiptail --msgbox 'auto mount like this: echo "<nfs-server-IP>:/   /mount_point   nfs    auto  0  0" >> /etc/fstab' $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}
########Install variable's########
do_install_nfs_server() {
  	apt-get install nfs-kernel-server -y
  	ufw allow 2049
  	whiptail --msgbox "You can broadcast your NFS server and set it up in webmin: https://$ADDRESS:10000" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT
}
########Install variable's########
do_install_ddclient() {
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
}
########Install variable's########
do_install_letsencrypt() {
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
}
########Install variable's########
do_install_rsync() {
  	apt-get install rsync -y
}
#########################################Update tool########################################################
do_update() {
  	apt-get autoclean
  	apt-get autoremove
  	apt-get update
  	apt-get upgrade -y
  	apt-get -f install
  	dpkg --configure --pending
}
#########################################Atomic toolkit########################################################
do_atomic() {
  	apt-get -y install git-core
	if 		[ -d /root/AtoMiC-ToolKit ];
  	then
	sleep 1
  	else
  	cd /root
  	git clone https://github.com/htpcBeginner/AtoMiC-ToolKit ~/AtoMiC-ToolKit
  	cd
  	fi
  
	cd ~/AtoMiC-ToolKit
  	bash setup.sh
  	cd
}
#########################################Multi Installer########################################################
# Interactive use loop
calc_wt_size
while true; do
  FUN=$(whiptail --title "https://www.techandme.se" --menu "Multi Installer" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
    "1 System tools" "Show LAN, WAN ip, change hostname and more" \
    "2 Firewall options" "Enable/disable firewall and allow or deny certain ports" \
    "3 Update system & tool" "Updates and upgrades packages and get the latest version of this tool" \
    "4 Install packages" "ClamAV, Teamspeak, Webmin, NFS, SSH etc." \
    "5 Atomic-Toolkit" "Use the tool to install Sonarr, Couchpotato, Sabnzbd etc."\
    "6 About Multi Installer" "Information about this tool" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    do_finish
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1\ *) do_tools ;;
      2\ *) do_firewall;;
      3\ *) do_update_full ;;
      4\ *) do_install_menu ;;
      5\ *) do_atomic ;;
      6\ *) do_about ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
done
