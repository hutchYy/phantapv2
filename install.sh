#!/bin/bash

# Function to list all network interfaces
list_interfaces() {
    echo "Available network interfaces:"
    ip link show | awk -F': ' '/^[0-9]+: /{print $2}' | awk -F'@' '{print $1}'
}

# Function to get the MAC address of a selected interface
get_mac_address() {
    local interface=$1
    ip link show "$interface" | awk '/link\/ether/{print $2}'
}

# Function to update udev rule with the MAC address
update_udev_rule() {
    local mac_address=$1
    local udev_file="/etc/udev/rules.d/70-persistent-net.rules"
    
    # Check if udev rules file exists
    if [[ -f "$udev_file" ]]; then
        # Replace the placeholder with the actual MAC address
        sudo sed -i "s/ATTR{address}==\"REPLACE\"/ATTR{address}==\"$mac_address\"/" "$udev_file"
        echo "Updated udev rule with MAC address: $mac_address"
    else
        echo "Error: udev rules file does not exist."
    fi
}

# Renaming interface of your choice to set it as phantap interface
set_phantap_udev() {
   echo "Listing all network interfaces..."
    list_interfaces

    # Prompt user to select an interface
    echo "Enter the name of the interface you want to check the MAC address for:"
    read selected_interface

    # Validate input
    if ip link show "$selected_interface" > /dev/null 2>&1; then
        mac_address=$(get_mac_address "$selected_interface")
        echo "The MAC address of $selected_interface is: $mac_address"
        update_udev_rule "$mac_address"
    else
        echo "Error: '$selected_interface' is not a valid interface."
    fi
}

# Check if sudo is installed
if ! command -v sudo &> /dev/null; then
    echo "sudo is not installed. Please install sudo and try again."
    exit 1

# Installing libraries used to compile phantap
sudo apt-get install -y make cmake build-essential libpcap-dev libnl-3-dev libnl-genl-3-dev bridge-utils dnsmasq

# Enable ip forwarding - DISABLED AS IT IS PERFORMED IN PRE-INIT SCRIPT
#if grep -q "^net.ipv4.ip_forward" /etc/sysctl.conf; then
  # Setting exists, modify it
#  sudo sed -i "s/^net.ipv4.ip_forward.*/net.ipv4.ip_forward=1/" /etc/sysctl.conf
#else
  # Setting does not exist, append it
#  echo "net.ipv4.ip_forward=1" | sudo tee -a /etc/sysctl.conf > /dev/null
#fi

# Disable IPv6 - DISABLED AS IT IS PERFORMED IN PRE-INIT SCRIPT
#echo "net.ipv6.conf.phantap.disable_ipv6=1" | sudo tee -a /etc/sysctl.conf > /dev/null

#sudo sysctl -p


# Enabling persistent dnsmasq
sudo systemctl enable dnsmasq
sudo systemctl start dnsmasq

# Define the build directory
BUILD_DIR="./src"
EXECUTABLE_NAME="phantap-learn"

# Step 1: Copy etc to /etc
echo "Copying startup files to init"
sudo cp ./files/etc/init.d/phantap /etc/init.d/phantap
sudo cp ./files/etc/init.d/phantap-early /etc/init.d/phantap-early

echo "Copying udev rules to udev"
sudo cp ./files/etc/udev/rules.d/99-phantap.rules /etc/udev/rules.d/99-phantap.rules

echo "Copying iptables rules"
DIR="/etc/iptables"
if [ ! -d "$DIR" ]; then
    sudo mkdir -p "$DIR"
fi
sudo cp ./files/etc/iptables/phantap  /etc/iptables/phantap

echo "Copying dnsmasq.d rules"
sudo cp ./files/etc/dnsmasq.d/phantap.conf /etc/dnsmasq.d/phantap.conf

echo "Copying networking"
sudo cp ./files/etc/network/interfaces.d/br-phantap.cfg  /etc/network/interfaces.d/br-phantap.cfg

# Renaming interface of your choice to set it as phantap interface - NOT NEEDED ANYMORE AS WE ARE USING DEFAULT INTERFACES
# set_phantap_udev


# Step 2: Compile the source file using cmake and make
echo "Compilation and installation of $EXECUTABLE_NAME completed."

# Navigate to the build directory
cd $BUILD_DIR

# Run cmake to generate the Makefile
cmake .

# Run make to compile the source file
make

# Step 3: Move the compiled executable to a desired location
echo "Moving compiled executable to /usr/sbin/$EXECUTABLE_NAME"
sudo cp ./$EXECUTABLE_NAME /usr/sbin/$EXECUTABLE_NAME

# Setting up phantap
echo "Performing the setup of phantap"
#sudo service phantap setup

# Setting up the uninstaller script
echo "Adding uninstall script to /usr/sbin/phantap-uninstall"
# Going back to the root folder
cd ..
chmod +x phantap-uninstall.sh
sudo cp ./phantap-uninstall.sh /usr/sbin/phantap-uninstall

# Rebooting to apply all settings
echo "Setup is done!"
echo "Do you want to reboot? (y/n)"
read reboot
if [ "$reboot" != "y" ]; then
    echo "The setup requires a reboot to work properly, reboot once you have time :)"
    exit 0
else
    echo "Rebooting..."
    sleep 3
    sudo reboot
