#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan skrip ini sebagai root!"
  exit 1
fi

# Variabel
NGINX_CONF_SNORT="/etc/nginx/sites-available/snort"
NGINX_CONF_COWRIE="/etc/nginx/sites-available/cowrie"

SNORT_IP="192.168.10.10"
WEB_SERVER_IP="192.168.30.100"

echo "### Update sistem dan instalasi Nginx ###"
apt update && apt upgrade -y
apt install -y nginx

echo "### Konfigurasi Nginx ###"
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

# Aktifkan konfigurasi Nginx
ln -sf $NGINX_CONF_SNORT /etc/nginx/sites-enabled/snort

# Hapus konfigurasi default Nginx
rm -f /etc/nginx/sites-enabled/default

echo "### Restart layanan Nginx ###"
systemctl restart nginx

echo "Konfigurasi Nginx selesai!"
