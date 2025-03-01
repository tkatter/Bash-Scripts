#! /bin/bash

/usr/bin/echo "What would you like to do?"

/usr/bin/echo "1 - See Hostname"
/usr/bin/echo "2 - View /etc/hosts"
/usr/bin/echo "3 - Edit /etc/hosts file"
/usr/bin/echo "4 - View Public IP Address"
/usr/bin/echo "5 - View status of all Interfaces"
/usr/bin/echo "6 - View NetworkManager status"

read netinfoCommand;

case $netinfoCommand in
    1) /usr/bin/echo "Your hostname is:" 
       /usr/bin/nmcli general hostname
       ;;
    2) /usr/bin/cat /etc/hosts;;
    3) sudo /usr/bin/nano /etc/hosts;;
    4) /usr/bin/echo "Your public IPV4 address is:"
       /usr/bin/curl ipv4.icanhazip.com
       ;;
    5) /usr/bin/nmcli -p d;;
    6) /usr/bin/nmcli -p general status
esac