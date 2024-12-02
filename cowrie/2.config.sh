#!/bin/bash

# Pastikan script dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
    echo "Silakan jalankan script ini sebagai root."
    exit 1
fi

echo "Mengupdate sistem dan menginstal dependensi..."
apt update && apt install -y python3 python3-venv git libssl-dev libffi-dev build-essential iptables

echo "Membuat user cowrie..."
adduser --disabled-password --gecos "" cowrie

echo "Menginstal Cowrie..."
su - cowrie -c "
git clone http://github.com/cowrie/cowrie.git && \
cd cowrie && \
python3 -m venv cowrie-env && \
source cowrie-env/bin/activate && \
pip install --upgrade pip && \
pip install --upgrade -r requirements.txt
"

echo "Mengonfigurasi Cowrie..."
sed -i '/\[telnet\]/a enabled = true' /home/cowrie/cowrie/etc/cowrie.cfg.dist
cp /home/cowrie/cowrie/etc/cowrie.cfg.dist /home/cowrie/cowrie/etc/cowrie.cfg

echo "Mengubah hostname default Cowrie menjadi 'webserver_palsu'..."
sed -i 's/^# \(hostname =\s*\).*/\1webserver_palsu/' /home/cowrie/cowrie/etc/cowrie.cfg

echo "Menambahkan iptables rules untuk redirect port..."
iptables -t nat -A PREROUTING -p tcp --dport 22 -j REDIRECT --to-port 2222
iptables -t nat -A PREROUTING -p tcp --dport 23 -j REDIRECT --to-port 2223

echo "Menjalankan Cowrie..."
su - cowrie -c "
cd cowrie && \
source cowrie-env/bin/activate && \
bin/cowrie start
"

echo "Mengatur hostname menjadi 'webserverpalsu'..."
hostnamectl set-hostname webserverpalsu
sed -i '/127.0.0.1/c\127.0.0.1   webserverpalsu' /etc/hosts

echo "Cowrie telah berhasil diinstal, dikonfigurasi, dan dijalankan dengan hostname 'webserver_palsu'."
