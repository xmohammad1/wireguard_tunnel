#!/bin/bash

# Function to show the menu
show_menu() {
    echo "Please choose a number:"
    echo "1) Iran"
    echo "2) Kharej"
    echo "3) Remove Wireguard"
    echo "9) Exit"
}

# Function to install WireGuard
install_wireguard() {
    # Check if WireGuard is installed
    if ! dpkg -l | grep -q wireguard; then
        echo "WireGuard is not installed. Installing WireGuard..."

        # Update the package list
        sudo apt-get update -qq

        # Install WireGuard
        sudo apt-get install -y wireguard -qq

        if [ $? -eq 0 ]; then
            echo "WireGuard installed successfully."
        else
            echo "Failed to install WireGuard."
            exit 1
        fi
    fi
}

# Function to configure WireGuard for Iran
Iran_wireguard_config() {
    cat > /etc/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = mP7Isgpp26x4SW6TdTBi/SK6n0zvXOBfajVCKRx/elA=
Address = 10.0.100.1/24
ListenPort = 51820

[Peer]
PublicKey = T5J5zL2t9mgZD+tEtVvuGb8pbQ6VF1YIeBEzVJXhARM=
AllowedIPs = 10.0.100.2/32
PersistentKeepalive = 25
EOF
    sudo wg-quick up wg0
    sudo systemctl enable wg-quick@wg0
    echo "WireGuard configuration for Iran has been set."
    ipv4_address=$(curl -s https://api.ipify.org)
    echo "Iran IPv4 is : $ipv4_address"
    read -p "Press Enter to continue..."
}

# Function to configure WireGuard for Kharej
kharej_wireguard_config() {
    read -p "Enter Your Iran IPv4: " iran_ip
    cat > /etc/wireguard/wg0.conf << EOF
[Interface]
PrivateKey = cCW9qQna3aALI9qyxaeR64oqV8x+y1jhvZlK8cF06UY=
Address = 10.0.100.2/24
ListenPort = 51820

[Peer]
PublicKey = LmgLMrg+eoM/MJiX65VqhlVDt0g/Vf6fF9hzaDnt0DM=
Endpoint = $iran_ip:51820
AllowedIPs = 10.0.100.1/32
PersistentKeepalive = 25
EOF
    sudo wg-quick up wg0
    sudo systemctl enable wg-quick@wg0
    echo "WireGuard configuration for Kharej has been set."
    echo "Kharej Wireguard IP is: 10.0.100.2"
    read -p "Press Enter to continue..."
}

# Function to remove WireGuard
remove_wireguard() {
    # Check if WireGuard is installed
    if dpkg -l | grep -q wireguard; then
        echo "WireGuard is installed. Removing WireGuard..."
        sudo wg-quick down wg0
        rm -rf /etc/wireguard/
        # Remove WireGuard and purge configuration files
        sudo apt-get remove --purge -y wireguard wireguard-tools
        sudo apt-get autoremove -y
        sudo apt-get autoclean

        if [ $? -eq 0 ]; then
            echo "WireGuard removed successfully."
        else
            echo "Failed to remove WireGuard."
            exit 1
        fi
    else
        echo "WireGuard is not installed."
    fi
    read -p "Press Enter to continue..."
}

# Loop until the user chooses to exit
while true; do
    show_menu
    read -p "Enter choice [1-9]: " choice
    case $choice in
        1)
            clear
            install_wireguard
            Iran_wireguard_config
            ;;
        2)
            clear
            install_wireguard
            kharej_wireguard_config
            ;;
        3)
            clear
            remove_wireguard
            ;;
        9)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice! Please select a valid option."
            ;;
    esac
done
