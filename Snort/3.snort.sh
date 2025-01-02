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

echo "### Update sistem dan instalasi Snort ###"
apt update && apt upgrade -y
apt install -y snort iptables-persistent

echo "### Konfigurasi Snort ###"
# Hentikan Snort jika sedang berjalan
systemctl stop snort

# Backup konfigurasi Snort
if [ -f "$SNORT_CONF" ]; then
  cp $SNORT_CONF ${SNORT_CONF}.bak
fi

# Konfigurasi Snort
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

echo "### Restart layanan Snort ###"
systemctl start snort

echo "Konfigurasi Snort selesai!"