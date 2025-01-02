#!/bin/bash

# Konfigurasi jaringan untuk Attacker
echo "Konfigurasi jaringan untuk Attacker..."

sudo apt update && sudo apt upgrade -y

sudo bash -c "cat > /etc/hostname << EOF
Attacker
EOF
"

sudo timedatectl set-timezone Asia/Jakarta

sudo bash -c "cat > /etc/netplan/50-cloud-init.yaml << EOF
network:
  version: 2
  ethernets:
    enp0s3:
        dhcp4: true
    enp0s8:
        dhcp4: no
        addresses:
          - 192.168.10.100/24
#sementara         gateway4: 192.168.10.10
        nameservers:
          addresses:
            - 8.8.8.8
            - 1.1.1.1
EOF
"

sudo netplan apply
echo "Konfigurasi jaringan untuk Attacker selesai!"

sudo reboot now