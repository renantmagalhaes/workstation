#!/bin/sh
#Root check
if [ “$(id -u)” != “0” ]; then
echo “This script must be run as root” 2>&1
exit 1
fi

#User check
echo "#########################"
echo "#			#"
echo "#	User Config	#"
echo "#			#"
echo "#########################"

echo "Enter your default user name:"
read user

#Add Key
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | apt-key add -
wget -q https://www.virtualbox.org/download/oracle_vbox.asc -O- | apt-key add -

#Register source.list
echo "deb https://download.virtualbox.org/virtualbox/debian stretch contrib" > /etc/apt/sources.list.d/virtualbox.list

#Install
apt-get update
apt-get install virtualbox-5.2
