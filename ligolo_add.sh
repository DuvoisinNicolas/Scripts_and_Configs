#!/bin/bash

username=$(whoami)

# Find the highest existing ligolo* interface number
existing_interfaces=$(ip link show | grep -oE 'ligolo[0-9]*' | sed 's/ligolo//' | sort -n | tail -1)
if [[ -z "$existing_interfaces" ]]; then
    if ip link show | grep -q "ligolo"; then
        counter=1  # Start from ligolo2 if ligolo exists
    else
        counter=0
    fi
else
    counter=$existing_interfaces
fi

while true; do
    read -p "Enter IP/Mask (or 'N' to stop): " input
    
    if [[ "$input" == "N" ]]; then
        echo "Exiting."
        break
    fi
    
    if [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        counter=$((counter + 1))
        if [[ $counter -eq 1 ]]; then
            interface="ligolo2"
        else
            interface="ligolo$counter"
        fi
        
        echo "Creating tunnel interface: $interface"
        sudo ip tuntap add user "$username" mode tun "$interface"
        sudo ip link set "$interface" up
        sudo ip route add "$input" dev "$interface"
    else
        echo "Invalid input. Please enter a valid IP/Mask or 'N' to stop."
    fi

done

