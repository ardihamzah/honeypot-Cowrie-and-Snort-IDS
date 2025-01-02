#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan skrip ini sebagai root!"
  exit 1
fi

# Variabel
APACHE_CONF="/etc/apache2/sites-available/webserver.conf"
WEB_ROOT="/var/www/webserver"
SERVER_NAME="webserver_asli"

echo "### Update sistem dan instalasi Apache ###"
apt update && apt upgrade -y
apt install -y apache2

echo "### Konfigurasi Apache ###"
# Buat direktori root untuk web server
if [ ! -d "$WEB_ROOT" ]; then
  mkdir -p $WEB_ROOT
fi

# Berikan hak akses yang sesuai
chown -R www-data:www-data $WEB_ROOT
chmod -R 755 $WEB_ROOT

# Buat file konfigurasi untuk Apache
cat > $APACHE_CONF <<EOL
<VirtualHost *:80>
    ServerName $SERVER_NAME
    DocumentRoot $WEB_ROOT

    <Directory $WEB_ROOT>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog \${APACHE_LOG_DIR}/webserver_error.log
    CustomLog \${APACHE_LOG_DIR}/webserver_access.log combined
</VirtualHost>
EOL

# Aktifkan konfigurasi dan modul yang diperlukan
a2ensite webserver.conf
a2enmod rewrite

# Nonaktifkan konfigurasi default jika tidak digunakan
a2dissite 000-default.conf

echo "### Restart layanan Apache ###"
systemctl restart apache2

# Tambahkan contoh halaman index.html
echo "### Membuat halaman web default ###"
cat > $WEB_ROOT/index.html <<EOL
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Web Server Apache</title>
</head>
<body>
    <h1>Selamat Datang di Web Server Apache!</h1>
    <p>Rudi Ardi Hamzah</p>
</body>
</html>
EOL

echo "Konfigurasi Apache selesai! Akses server menggunakan http://$SERVER_NAME atau IP server."