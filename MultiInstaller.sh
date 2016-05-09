#!/bin/sh
# Part of raspi-config http://github.com/asb/raspi-config
#
# See LICENSE file for copyright and license details

INTERACTIVE=True
ASK_TO_REBOOT=0
BLACKLIST=/etc/modprobe.d/raspi-blacklist.conf
CONFIG=/boot/config.txt
SCRIPTS=/var/scripts

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
This tool provides a straight-forward way of doing initial
configuration of the Raspberry Pi. Although it can be run
at any time, some of the options may have difficulties if
you have heavily customised your installation.\
" 20 70 1
}

#########################################Firewall########################################################

do_firewall() {
  FUN=$(whiptail --title "Firewall" --menu "UFW Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
    "A1 Enable Firewall" "" \
    "A2 Disable Firewall" "" \
    "A3 Allow port xxx" "xxx" \
    "A4 Allow port 32400" "Plex" \
    "A5 Allow port 8989" "Sonarr" \
    "A6 Allow port 5050" "Couchpotato" \
    "A7 Allow port 8181" "Headphones" \
    "A8 Allow port 8085" "HTPC Manager" \
    "A9 Allow port xxx" "Sickbeard" \
    "A10 Allow port 10000" "Webmin" \
    "A11 Allow port 8080" "Sabnzbdplus" \
    "A12 Allow port 9090" "Sabnzbdplus https" \
    "A13 Allow port xxx" "xxx" \
    "A14 Deny port xxx" "xxx" \
    "A15 Deny port xxx" "xxx" \
    "A16 Deny port xxx" "xxx" \
    "A17 Deny port xxx" "xxx" \
    "A18 Deny port xxx" "xxx" \
    "A19 Deny port xxx" "xxx" \
    "A20 Deny port xxx" "xxx" \
    "A21 Deny port xxx" "xxx" \
    "A22 Deny port xxx" "xxx" \
    "A23 Deny port xxx" "xxx" \
    "A24 Deny port xxx" "xxx" \
    "A25 Deny port xxx" "xxx" \
    "A26 Deny port xxx" "xxx" \
    "A27 Deny port xxx" "xxx" \
    "A28 Deny port xxx" "xxx" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      A1\ *) do_ufw_enable ;;
      A2\ *) do_ufw_disable ;;
      A3\ *) do_allow_ ;;
      A4\ *) do_allow_32400 ;;
      A5\ *) do_allow_8989 ;;
      A6\ *) do_allow_5050 ;;
      A7\ *) do_allow_8181 ;;
      A8\ *) do_allow_8085 ;;
      A9\ *) do_allow_ ;;
      A10\ *) do_allow_10000 ;;
      A11\ *) do_allow_8080 ;;
      A12\ *) do_allow_9090 ;;
      A13\ *) do_allow_ ;;
      A14\ *) do_deny_ ;;
      A15\ *) do_deny_ ;;
      A16\ *) do_deny_ ;;
      A17\ *) do_deny_ ;;
      A18\ *) do_deny_ ;;
      A19\ *) do_deny_ ;;
      A20\ *) do_deny_ ;;
      A21\ *) do_deny_ ;;
      A22\ *) do_deny_ ;;
      A23\ *) do_deny_ ;;
      A24\ *) do_deny_ ;;
      A25\ *) do_deny_ ;;
      A26\ *) do_deny_ ;;
      A27\ *) do_deny_ ;;
      A28\ *) do_deny_ ;;
      A29\ *) do_deny_ ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
}

######Tools variable's#######
do_show_wan() {
sudo ufw enable
}

#########################################Firewall########################################################

do_firewall() {
  FUN=$(whiptail --title "Firewall" --menu "UFW Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
    "A1 Enable Firewall" "" \
    "A2 Disable Firewall" "" \
    "A3 Allow port xxx" "xxx" \
    "A4 Allow port 32400" "Plex" \
    "A5 Allow port 8989" "Sonarr" \
    "A6 Allow port 5050" "Couchpotato" \
    "A7 Allow port 8181" "Headphones" \
    "A8 Allow port 8085" "HTPC Manager" \
    "A9 Allow port xxx" "Sickbeard" \
    "A10 Allow port 10000" "Webmin" \
    "A11 Allow port 8080" "Sabnzbdplus" \
    "A12 Allow port 9090" "Sabnzbdplus https" \
    "A13 Allow port xxx" "xxx" \
    "A14 Deny port xxx" "xxx" \
    "A15 Deny port xxx" "xxx" \
    "A16 Deny port xxx" "xxx" \
    "A17 Deny port xxx" "xxx" \
    "A18 Deny port xxx" "xxx" \
    "A19 Deny port xxx" "xxx" \
    "A20 Deny port xxx" "xxx" \
    "A21 Deny port xxx" "xxx" \
    "A22 Deny port xxx" "xxx" \
    "A23 Deny port xxx" "xxx" \
    "A24 Deny port xxx" "xxx" \
    "A25 Deny port xxx" "xxx" \
    "A26 Deny port xxx" "xxx" \
    "A27 Deny port xxx" "xxx" \
    "A28 Deny port xxx" "xxx" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      A1\ *) do_ufw_enable ;;
      A2\ *) do_ufw_disable ;;
      A3\ *) do_allow_ ;;
      A4\ *) do_allow_32400 ;;
      A5\ *) do_allow_8989 ;;
      A6\ *) do_allow_5050 ;;
      A7\ *) do_allow_8181 ;;
      A8\ *) do_allow_8085 ;;
      A9\ *) do_allow_ ;;
      A10\ *) do_allow_10000 ;;
      A11\ *) do_allow_8080 ;;
      A12\ *) do_allow_9090 ;;
      A13\ *) do_allow_ ;;
      A14\ *) do_deny_ ;;
      A15\ *) do_deny_ ;;
      A16\ *) do_deny_ ;;
      A17\ *) do_deny_ ;;
      A18\ *) do_deny_ ;;
      A19\ *) do_deny_ ;;
      A20\ *) do_deny_ ;;
      A21\ *) do_deny_ ;;
      A22\ *) do_deny_ ;;
      A23\ *) do_deny_ ;;
      A24\ *) do_deny_ ;;
      A25\ *) do_deny_ ;;
      A26\ *) do_deny_ ;;
      A27\ *) do_deny_ ;;
      A28\ *) do_deny_ ;;
      A29\ *) do_deny_ ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
}

######Firewall variable's#######
do_ufw_enable() {
sudo ufw enable
}

do_ufw_disable() {
sudo ufw disable
}

do_allow_32400() {
sudo ufw allow 32400
}

do_allow_10000() {
sudo ufw allow 10000
}

do_allow_5050() {
sudo ufw allow 5050
}

do_allow_9090() {
sudo ufw allow 9090
}

do_allow_8080() {
sudo ufw allow 8080
}

do_allow_8989() {
sudo ufw allow 8989
}

do_allow_8181() {
sudo ufw allow 8181
}

do_allow_8085() {
sudo ufw allow 8085
}

do_deny_32400() {
sudo ufw deny 32400
}

do_deny_10000() {
sudo ufw deny 10000
}

do_deny_5050() {
sudo ufw deny 5050
}

do_deny_9090() {
sudo ufw deny 9090
}

do_deny_8080() {
sudo ufw deny 8080
}

do_deny_8989() {
sudo ufw deny 8989
}

do_deny_8181() {
sudo ufw deny 8181
}

do_deny_8085() {
sudo ufw deny 8085
}

#########################################Password########################################################

do_change_pass() {
  whiptail --msgbox "You will now be asked to enter a new password for the ubuntu user" 20 60 1
  passwd ubuntu &&
  whiptail --msgbox "Password changed successfully" 20 60 1
}

#########################################Internationalisation########################################################

do_internationalisation_menu() {
  FUN=$(whiptail --title "Raspberry Pi Software Configuration Tool (raspi-config)" --menu "Internationalisation Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
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

do_configure_keyboard() {
  dpkg-reconfigure keyboard-configuration &&
  printf "Reloading keymap. This may take a short while\n" &&
  invoke-rc.d keyboard-setup start
}

do_change_locale() {
  dpkg-reconfigure locales
}

do_change_timezone() {
  dpkg-reconfigure tzdata
}

#########################################Change hostname########################################################

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

#########################################Upgrade and update system and tool########################################################

do_update() {
  apt-get update &&
  apt-get upgrade -y
  rm $SCRIPTS/tool.sh  
  mkdir -p $SCRIPTS && 
  wget https://github.com/ezraholm50/MultiInstaller/tool.sh -P $SCRIPTS/ &&
  printf "Sleeping 5 seconds before reloading the Multi Installer\n" &&
  sleep 5 &&
  bash $SCRIPTS/tool.sh
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

do_advanced_menu() {
  FUN=$(whiptail --title "Raspberry Pi Software Configuration Tool (raspi-config)" --menu "Advanced Options" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Back --ok-button Select \
    "A1 Install Plex" "Media server" \
    "A2 Install Webmin" "Graphical interface to manage headless systems" \
    "A3 Install SSH Server" "Needed by a remote machine to be accessable via SSH" \
    "A4 Install SSH Client" "Needed by the local machine to connect to a remote machine" \
    "A5 Enable/Disable SSH" "Enable/Disable remote command line access to your Pi using SSH" \
    "A6 Install ClamAV" "Install Antivirus software and set daily scans, infected will be moved to /infected" \
    "A7 Install Fail2Ban" "Install a failed login monitor, needs jails so it won't work out of the box" \
    "A8 Install Nginx" "Install Nginx webserver" \
    "A9 Install Teamspeak" "Install Teamspeak 3 server to do voice chat" \
    "A10 Install NFS Client" "Install NFS client to be able to mount NFS shares" \
    "A11 Install NFS Server" "Install NFS server to be able to broadcast NFS shares" \
    "A12 Install DDClient" "Update your Dynamic Dns with your current WAN IP, supports dyndns.com, easydns.com etc." \
    "A13 Install Letsencrypt" "Install free valid SSL certificates with your domain name (www.yourdomain.com)" \
    "A14 Install Rsync" "Install a sync package to backup/copy filesystems/folders/files" \
    "A15 Install NFS Client" "Install NFS client to be able to mount NFS shares" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    return 0
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      A1\ *) do_install_plex ;;
      A2\ *) do_install_webmin ;;
      A3\ *) do_install_SSH_server ;;
      A4\ *) do_install_SSH_client ;;
      A5\ *) do_ssh ;;
      A6\ *) do_clamav ;;
      A7\ *) do_fail2ban ;;
      A8\ *) do_nginx ;;
      A9\ *) do_teamspeak ;;
      A10\ *) do_install_nfs_client ;;
      A11\ *) do_install_nfs_server ;;
      A12\ *) do_install_ddclient ;;
      A13\ *) do_install_letsencrypt ;;
      A14\ *) do_install_rsync ;;
      A15\ *) do_update ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  fi
}

#do_install_plex() {
#}

#########################################Multi Installer########################################################

# Interactive use loop
#
calc_wt_size
while true; do
  FUN=$(whiptail --title "https://www.techandme.se" --menu "Multi Installer" $WT_HEIGHT $WT_WIDTH $WT_MENU_HEIGHT --cancel-button Finish --ok-button Select \
    "1 System tools" "Show a bunch of system stats" \
    "2 Change User Password" "Change password for the default user (ubuntu)" \
    "3 xxx" "xxx" \
    "4 Internationalisation Options" "Set up language and regional settings to match your location" \
    "5 Upgrade your distribution" "Tested on Ubuntu" \
    "6 Firewall options" "Choose whether to boot into a desktop environment, Scratch, or the command-line" \
    "7 Update system & tool" "Updates and upgrades packages and get the latest version of this tool" \
    "8 Install packages" "ClamAV, Teamspeak, Webmin, NFS, SSH etc." \
    "9 About Multi Installer" "Information about this tool" \
    3>&1 1>&2 2>&3)
  RET=$?
  if [ $RET -eq 1 ]; then
    do_finish
  elif [ $RET -eq 0 ]; then
    case "$FUN" in
      1\ *) do_details ;;
      2\ *) do_change_pass ;;
      3\ *) do_boot_behaviour ;;
      4\ *) do_internationalisation_menu ;;
      5\ *) do_dist_upgrade ;;
      6\ *) do_firewall ;;
      7\ *) do_update ;;
      8\ *) do_install_menu ;;
      9\ *) do_about ;;
      *) whiptail --msgbox "Programmer error: unrecognized option" 20 60 1 ;;
    esac || whiptail --msgbox "There was an error running option $FUN" 20 60 1
  else
    exit 1
  fi
done
