#!/bin/sh

echo "Removing the phantap init script..."
sudo rm /etc/init.d/phantap

echo "Removing the phantap-early init script..."
sudo rm /etc/init.d/phantap-early

echo "Removing the phantap udev rules..."
sudo rm /etc/udev/rules.d/99-phantap.rules

echo "Removing the phantap iptables configuration..."
sudo rm /etc/iptables/phantap

echo "Removing the phantap dnsmasq configuration..."
sudo rm /etc/dnsmasq.d/phantap.conf

echo "Removing the phantap network interface configuration..."
sudo rm /etc/network/interfaces.d/br-phantap.cfg

echo "Removing the phantap-learn script..."
sudo rm /usr/sbin/phantap-learn

echo "Removing the phantap-uninstall script..."
sudo rm -- "$0"

echo "Uninstallation process completed."
