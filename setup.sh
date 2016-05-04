#
# Ezra

# must be root
apt-get update && apt-get upgrade -y && apt-get -f install -y
apt-get install openssh-server nano sudo dialog linux-firmware 

# webmin
wget http://prdownloads.sourceforge.net/webadmin/webmin_1.791_all.deb -P /tmp/
apt-get install perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl apt-show-versions python -y
dpkg --install /tmp/webmin_1.791_all.deb

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
else
      sleep 1
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
      sleep 1
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
      sleep 1
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
      sleep 1
fi
