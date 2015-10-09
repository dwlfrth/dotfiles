#!/bin/bash


getIP() {
    ifconfig $1 | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p'
}

# Define ethernet interfaces and IPs here.
# Use the getIP function to parse the IP address from the defined interface
export ifPublic="eth0"
export ifPublicIP=$(getIP $ifPublic)


firewall-on() {
    # Flush iptables
    iptables -F
    iptables -t nat -F

    # Default rules
    iptables -P INPUT DROP
    iptables -P FORWARD DROP
    iptables -P OUTPUT ACCEPT

    # Sanity check
    # Making sure that nothing is coming from known CIDR private classes on the public interface (Internet)
    # Useful only when we use this script as a NATting firewall script (in the case of a gateway per example)
    iptables -A INPUT -i $ifPublic -s 127.0.0.1/32 -j DROP
    iptables -A FORWARD -i $ifPublic -s 127.0.0.1/32 -j DROP
    iptables -A INPUT -i $ifPublic -s 10.0.0.0/8 -j DROP
    iptables -A FORWARD -i $ifPublic -s 10.0.0.0/8 -j DROP
    iptables -A INPUT -i $ifPublic -s 172.16.0.0/12 -j DROP
    iptables -A FORWARD -i $ifPublic -s 172.16.0.0/12 -j DROP
    iptables -A INPUT -i $ifPublic -s 192.168.0.0/16 -j DROP
    iptables -A FORWARD -i $ifPublic -s 192.168.0.0/16 -j DROP

    # Ping accept
    iptables -A INPUT -i $ifPublic -p icmp -d $ifPublicIP/32 -m icmp --icmp-type 3 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -i $ifPublic -p icmp -d $ifPublicIP/32 -m icmp --icmp-type 8 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -i $ifPublic -p icmp -d $ifPublicIP/32 -m icmp --icmp-type 11 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT -i $ifPublic -p icmp -d $ifPublicIP/32 -m icmp --icmp-type 30 -m conntrack --ctstate NEW,ESTABLISHED -j ACCEPT


    ### INPUT ###
    # Default (Loopback and related/established connections)
    iptables -A INPUT -i lo -j ACCEPT
    iptables -A INPUT -i $ifPublic -d $ifPublicIP/32 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    # - SERVICES -
    # Add services specific rules under there


    ### FORWARD ###
    # Default (Related/established connections)
    iptables -A FORWARD -i $ifPublic -d $ifPublicIP/32 -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

    # - SERVICES -
    # Add services specific rules under there


    ### INTERNET ###
    # Various rules useful when you want to use this script as a gateway / firewall / NATting
#    iptables -A INPUT -i $ifPrivate -j ACCEPT
#    iptables -A FORWARD -i $ifPrivate -j ACCEPT
#    iptables -A POSTROUTING -t nat -o $ifPublic -j MASQUERADE
#    iptables -A FORWARD -i $ifPublic -o $ifPrivate -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT


    ### LOGS ###
    # Defined last to only log denied connections
    iptables -A INPUT -m limit --limit 1/min -j LOG --log-prefix "[ipt(I)]: " --log-level 7
    iptables -A FORWARD -m limit --limit 1/min -j LOG --log-prefix "[ipt(F)]: " --log-level 7
}


firewall-off() {
    # Flush iptables
    iptables -F
    iptables -t nat -F

    # Default rules
    iptables -P INPUT ACCEPT
    iptables -P FORWARD ACCEPT
    iptables -P OUTPUT ACCEPT

    # NATting (We want to keep NATting even if firewall is off (default ruleset))
    # Useful only when using this script as a gateway / firewall / NATting
#    iptables -A POSTROUTING -t nat -o $ifPublic -j MASQUERADE
}


case $1 in
    start)
        echo "Applying iptables personalized ruleset: FIREWALL ON!"
        firewall-on
        ;;
    stop)
        echo "Applying iptables default ruleset: FIREWALL OFF!"
        firewall-off
        ;;
    restart)
        echo "Applying iptables default ruleset: FIREWALL OFF!"
        firewall-off
        echo "Applying iptables personalized ruleset: FIREWALL ON!"
        firewall-on
        ;;
    status)
        iptables -nvL
        ;;
esac


exit 0
