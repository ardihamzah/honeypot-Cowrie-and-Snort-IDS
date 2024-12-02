#!/bin/bash

# Konfigurasi jaringan untuk Web Server
echo "Konfigurasi jaringan untuk Web Server..."

sudo apt update && sudo apt upgrade -y

sudo bash -c "cat > /etc/hostname << EOF
webserver
EOF
"

sudo timedatectl set-timezone Asia/Jakarta

sudo bash -c "cat > /etc/netplan/50-cloud-init.yaml << EOF
network:
  version: 2
  ethernets:
    enp0s3:
        dhcp4: true #opsional jika butuh inet
    enp0s8:
        dhcp4: no
        addresses:
          - 192.168.30.100/24
#sementara        gateway4: 192.168.30.10
        nameservers:
          addresses:
            - 8.8.8.8
            - 1.1.1.1
EOF
"

sudo netplan apply
echo "Konfigurasi jaringan untuk Web Server selesai!"

sudo reboot now