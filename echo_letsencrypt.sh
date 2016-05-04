#!/bin/bash
#
# Tech and Me, 2016 - www.techandme.se
#
	cat << STARTMSG
+---------------------------------------------------------------+
|       Important! Please read this!                            |
|                                                               |
|       This script will install SSL from Let's Encrypt.        |
|       It's free of charge, and very easy to use.              |
|                                                               |
|       Before we begin the installation you need to have       |
|       a domain.                                               |
|       If you don't have a domian yet, get one before          |
|       you run this script!                                    |
|							                                                	|
|       You also have to open port 443 against this machine     |
|       IP address: $ADDRESS - do this in your router.  |
|       Here is a guide: https://goo.gl/Uyuf65                  |
|                                                               |
|       This script is located in /var/scripts and you          |
|       can run this script after you got a domain.             |
|                                                               |
|       Please don't run this script if you don't have		      |
|       a domain yet. You can get one for a fair price here:	  |
|       https://www.citysites.eu/                               |
|                                                               |
+---------------------------------------------------------------+

STARTMSG
exit
