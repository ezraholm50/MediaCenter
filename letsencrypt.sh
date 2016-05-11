#!/bin/sh
#
# Tech and Me, 2016 - www.techandme.se
#
# See LICENSE file for copyright and license details
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
	cat << STARTMSG
+---------------------------------------------------------------+
|       Important! Please read this!                            |
|                                                               |
|       This script will install SSL from Let's Encrypt.        |
|       It's free of charge, and very easy to use.              |
|                                                               |
|       Before we begin the installation you need to have       |
|       a domain that the SSL certs will be valid for.          |
|       If you don't have a domian yet, get one before          |
|       you run this script!                                    |
|								|
|       You also have to open port 443 against this machine     |
|       IP address: $ADDRESS - do this in your router.  |
|       Here is a guide: https://goo.gl/Uyuf65                  |
|                                                               |
|       This script is located in /var/scripts and you          |
|       can run this script after you got a domain.             |
|                                                               |
|       Please don't run this script if you don't have		|
|       a domain yet. You can get one for a fair price here:	|
|       https://www.citysites.eu/                               |
|                                                               |
+---------------------------------------------------------------+

STARTMSG

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
exit
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
exit
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
exit
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
sleep 1
fi

exit 0
