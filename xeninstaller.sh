#!/bin/bash
# Xen Hypervisor 4.1 Install on Debian Wheezy
# Author: John McCarthy
# Date: July 31, 2013
#
# To God only wise, be glory through Jesus Christ forever. Amen.
# Romans 16:27, I Corinthians 15:1-4
#------------------------------------------------------
######## FUNCTIONS ########
function installXen()
{
	echo -e '\e[33m+++ Installing Xen 4.1 and required packages...\e[0m'
	apt-get -y install xen-linux-system-amd64 xen-tools xen-utils-4.1 xen-hypervisor-4.1-amd64
	echo -e '\e[1;37;42mXen 4.1 has been installed successfully!\e[0m'
}
function updateGrub()
{
	echo -e '\e[33m+++ Editing your grub boot priority...\e[0m'
	mv /etc/grub.d/20_linux_xen /etc/grub.d/09_linux_xen
	update-grub
	echo -e '\e[1;37;42mYour grub boot priority has been edited successfully!\e[0m'
}
function editMem()
{
	echo -e '\e[33mHow much RAM would you like Xen'\''s Dom0 to use? \n(In MB, E.g. 4096 for 4GB or 4096MB of RAM)\e[0m'
	read MEM
	echo -e '\e[33m+++ Editing /etc/default/grub...\e[0m'
	grep -q "XEN" /etc/default/grub | sed -i '/XEN/d' /etc/default/grub
	echo 'GRUB_CMDLINE_XEN_DEFAULT='"dom0_mem=$MEM"'' >> /etc/default/grub
	echo -e '\e[1;37;42m/etc/default/grub has been edited successfully!\e[0m'
	echo
	echo -e '\e[33m+++ Editing /etc/xen/xend-config.sxp...\e[0m'
	sed -i 's/(dom0-min-mem 196)/(dom0-min-mem $MEM)/g' /etc/xen/xend-config.sxp
	sed -i 's/(enable-dom0-ballooning yes)/(enable-dom0-ballooning no)/g' /etc/xen/xend-config.sxp
	update-grub
	echo -e '\e[1;37;42mYour Xen'\''s Dom0 minimum memory has been edited successfully!\e[0m'
}
function installVirt()
{
	echo -e '\e[33m+++ Installing virt-manager...\e[0m'
	apt-get -y install virt-manager
	echo -e '\e[1;37;42mVirt-manager has been installed successfully!\e[0m'
	echo
	echo -e '\e[33m+++ Editing /etc/xen/xend-config.sxp...\e[0m'
	sed -i 's/#(xend-http-server no)/(xend-http-server yes)/g' /etc/xen/xend-config.sxp
	sed -i 's/#(xend-unix-server no)/(xend-unix-server yes)/g' /etc/xen/xend-config.sxp
	sed -i 's/#(xend-tcp-xmlrpc-server no)/(xend-tcp-xmlrpc-server yes)/g' /etc/xen/xend-config.sxp
	sed -i 's/#(xend-unix-xmlrpc-server yes)/(xend-unix-xmlrpc-server yes)/g' /etc/xen/xend-config.sxp
	echo -e '\e[1;37;42m/etc/xen/xend-config.sxp has been edited successfully!\e[0m'
}
function setupBridge()
{
	echo -e '\e[33mWhat IP address would you like to use?\e[0m'
	read IP
	echo -e '\e[33mWhat netmask would you like to use?\e[0m'
	read NETMASK
	echo -e '\e[33mWhat gateway would you like to use?\e[0m'
	read GATEWAY
	echo -e '\e[33m+++ Editing /etc/network/interfaces...\e[0m'
	echo -e "auto lo
iface lo inet loopback

iface eth0 inet manual
auto xenbr0

iface xenbr0 inet static
        bridge_ports eth0
        address $IP
        netmask $NETMASK
        gateway $GATEWAY" > /etc/network/interfaces
	service networking restart
	echo -e '\e[1;37;42mYour network bridge "xenbr0" has been setup successfully!\e[0m'
}
function setupWOL()
{
	echo -e '\e[33m+++ Installing ethtool...\e[0m'
	apt-get -y install ethtool
	echo -e '\e[1;37;42mEthtool has been installed successfully!\e[0m'
	echo
	echo -e '\e[33m+++ Editing /etc/network/interfaces...\e[0m'
	echo -e "\nethernet-wol g" >> /etc/network/interfaces
	service networking restart
	echo -e '\e[1;37;42m/etc/network/interfaces has been edited successfully!\e[0m'
}
function doAll()
{
	echo
	echo -e '\e[33m=== Install Xen 4.1 ? (y/n)\e[0m'
	read yesno
	if [ "$yesno" = "y" ]; then
		installXen
	fi

	echo
	echo -e '\e[33m=== Edit Your Xen Hypervisor'\''s boot priority ? (y/n)\e[0m'
	read yesno
	if [ "$yesno" = "y" ]; then
		updateGrub
	fi

	echo
	echo -e '\e[33m=== Edit Xen'\''s Dom0 Minimum Memory ? (y/n)\e[0m'
	read yesno
	if [ "$yesno" = "y" ]; then
		editMem
	fi

	echo
	echo -e '\e[33m=== Install Virt-Manager ? (y/n)\e[0m'
	read yesno
	if [ "$yesno" = "y" ]; then
		installVirt
	fi

	echo
	echo -e '\e[33m=== Would you like to setup a Network Bridge (xenbr0) ? (y/n)\e[0m'
	read yesno
	if [ "$yesno" = "y" ]; then
		setupBridge
	fi

	echo
	echo -e '\e[33m=== Would you like to setup WOL ? (y/n)\e[0m'
	read yesno
	if [ "$yesno" = "y" ]; then
		setupWOL
	fi
	echo
	echo
	echo -e '         \e[01;37;42mWell done! You have completed your Xen Hypervisor Installation!\e[0m'
	echo
	echo
	echo -e '\e[01;37mCheckout similar material at "midactstech.blogspot.com" and "github.com/Midacts" \e[0m'
	echo
	echo -e '                            \e[01;37m########################\e[0m'
	echo -e '                            \e[01;37m#\e[0m \e[31mI Corinthians 15:1-4\e[0m \e[01;37m#\e[0m'
	echo -e '                            \e[01;37m########################\e[0m'
	echo
	echo
	exit 0
}
# Check privileges
[ $(whoami) == "root" ] || die "You need to run this script as root."
# Welcome to the script
echo
echo -e '              \e[01;37;42mWelcome to Midacts Mystery'\''s Puppet Agent Installer!\e[0m'
echo
echo -e '                \e[00;31;40m!!! Do not forget to edit your DNS settings !!!\e[0m'
####### MENU #######
case "$go" in
	install)
		installXen ;;
	grub)
		updateGrub ;;
	mem)
		editMem ;;
	virtman)
		installVirt ;;
	bridge)
		setupBridge ;;
	wol)
		setupWOL ;;
	* )
		doAll ;;
esac

exit 0
