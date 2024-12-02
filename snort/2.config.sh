#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan skrip ini sebagai root!"
  exit 1
fi

# Variabel
RULES_DIR="/etc/snort/rules"
SNORT_CONF="/etc/snort/snort.conf"

SNORT_IP="192.168.10.10"
WEB_SERVER_IP="192.168.30.100"
COWRIE_IP="192.168.10.20"

echo "### Update sistem dan instalasi dependensi ###"
apt update && apt upgrade -y
apt install -y snort nginx iptables-persistent

echo "### Konfigurasi Snort ###"
# Hentikan Snort jika sedang berjalan
systemctl stop snort

# Backup konfigurasi Snort
if [ -f "$SNORT_CONF" ]; then
  cp $SNORT_CONF ${SNORT_CONF}.bak
fi

# Tambahkan definisi variabel RULE_PATH dan konfigurasinya
cat > $SNORT_CONF <<EOL
# Define network variables
ipvar HOME_NET [192.168.10.10,192.168.10.20,192.168.30.100]
ipvar EXTERNAL_NET any

# Define rule path
var RULE_PATH /etc/snort/rules

# Include rule files
include \$RULE_PATH/local.rules
include \$RULE_PATH/ddos.rules
include \$RULE_PATH/brute-force.rules

# Output configuration
output alert_fast: stdout
EOL

# Periksa dan buat direktori rules jika belum ada
if [ ! -d "$RULES_DIR" ]; then
  mkdir -p $RULES_DIR
fi

# Tambahkan rules untuk deteksi DDoS dan Brute-Force
cat > $RULES_DIR/ddos.rules <<EOL
# Rule untuk mendeteksi HTTP Flood
alert tcp any any -> \$HOME_NET 80 (msg:"HTTP Flood Detected"; flags:S; threshold:type both, track by_dst, count 20, seconds 5; sid:1000002; rev:1;)
EOL

cat > $RULES_DIR/brute-force.rules <<EOL
# Rule untuk mendeteksi brute-force SSH
alert tcp any any -> \$HOME_NET 22 (msg:"SSH Brute-Force Detected"; flow:to_server,established; detection_filter:track by_src, count 5, seconds 60; sid:1000001; rev:1;)
EOL

echo "### Validasi konfigurasi Snort ###"
if snort -T -c $SNORT_CONF -i eth0; then
  echo "Konfigurasi Snort valid."
else
  echo "Error: Konfigurasi Snort tidak valid."
  exit 1
fi

echo "### Konfigurasi Nginx ###"
NGINX_CONF_SNORT="/etc/nginx/sites-available/snort"
NGINX_CONF_COWRIE="/etc/nginx/sites-available/cowrie"

# Konfigurasi Nginx untuk Snort
cat > $NGINX_CONF_SNORT <<EOL
server {
    listen 80;
    server_name $SNORT_IP;

    location / {
        proxy_pass http://$WEB_SERVER_IP;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOL

# Konfigurasi Nginx untuk Cowrie
cat > $NGINX_CONF_COWRIE <<EOL
server {
    listen 80;
    server_name $COWRIE_IP;

    location / {
        proxy_pass http://$WEB_SERVER_IP;
        proxy_set_header Host \$host;
        proxy_set_header X-Real-IP \$remote_addr;
    }
}
EOL

# Aktifkan konfigurasi Nginx
ln -sf $NGINX_CONF_SNORT /etc/nginx/sites-enabled/snort
ln -sf $NGINX_CONF_COWRIE /etc/nginx/sites-enabled/cowrie

# Hapus konfigurasi default Nginx
rm -f /etc/nginx/sites-enabled/default

echo "### Restart layanan Nginx ###"
systemctl restart nginx

#echo "### Konfigurasi Firewall dengan iptables ###"
# Blok akses langsung ke Webserver
#iptables -A FORWARD -s 192.168.10.0/24 -d $WEB_SERVER_IP -j DROP

# Redirect trafik ke Snort
#iptables -t nat -A PREROUTING -s 192.168.10.0/24 -d $SNORT_IP -p tcp --dport 80 -j DNAT --to-destination $WEB_SERVER_IP:80

# Redirect trafik ke Cowrie
#iptables -t nat -A PREROUTING -s 192.168.10.0/24 -d $COWRIE_IP -p tcp --dport 80 -j DNAT --to-destination $WEB_SERVER_IP:80

# Simpan aturan iptables
#netfilter-persistent save

echo "### Restart layanan Snort ###"
systemctl start snort

echo "Konfigurasi selesai! Pastikan untuk menguji akses ke IP Snort ($SNORT_IP) dan Cowrie ($COWRIE_IP) untuk memeriksa apakah halaman Webserver muncul."