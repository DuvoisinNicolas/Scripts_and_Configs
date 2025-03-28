#!/bin/bash

counter=0
username=$(whoami)

# Delete existing ligolo* interfaces
existing_interfaces=$(ip link show | grep -oE 'ligolo[0-9]*')
for iface in $existing_interfaces; do
    sudo ip link delete "$iface"
done

echo "Existing ligolo* interfaces deleted."

while true; do
    read -p "Enter IP/Mask (or 'N' to stop): " input
    
    if [[ "$input" == "N" ]]; then
        echo "Exiting."
        break
    fi
    
    if [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+/[0-9]+$ ]]; then
        counter=$((counter + 1))
        if [[ $counter -eq 1 ]]; then
            interface="ligolo"
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

