#!/bin/bash

# Konfigurasi jaringan untuk Snort
echo "Konfigurasi jaringan untuk Snort..."

sudo apt update && sudo apt upgrade -y

sudo bash -c "cat > /etc/hostname << EOF
snort
EOF
"

sudo timedatectl set-timezone Asia/Jakarta

sudo bash -c "cat > /etc/netplan/50-cloud-init.yaml << EOF
network:
  version: 2
  ethernets:
    enp0s3:
        dhcp4: no
        addresses:
          - 192.168.10.10/24
    enp0s8:
        dhcp4: no
        addresses:
          - 192.168.10.20/24
    enp0s9:
        dhcp4: no
        addresses:
          - 192.168.30.10/24
    enp0s10:
        dhcp4: true #opsional jika butuh inet (buka tutup)
EOF
"

sudo netplan apply

# Mengaktifkan IP forwarding
echo "Mengaktifkan IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo bash -c "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf"
sudo sysctl -p

echo "Konfigurasi jaringan untuk Snort selesai!"

sudo reboot now
