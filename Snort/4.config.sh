#!/bin/bash

# Pastikan skrip dijalankan sebagai root
if [ "$(id -u)" -ne 0 ]; then
  echo "Jalankan skrip ini sebagai root!"
  exit 1
fi

# Lokasi file cadangan konfigurasi Snort
SNORT_CONF_BAK="snort.conf.bak"
SNORT_CONF="/etc/snort/snort.conf"

echo "### Memeriksa file cadangan konfigurasi ###"
if [ -f "$SNORT_CONF_BAK" ]; then
  echo "File cadangan ditemukan. Memulihkan konfigurasi Snort..."
  mv "$SNORT_CONF_BAK" "$SNORT_CONF"
  echo "Konfigurasi Snort berhasil dipulihkan."
else
  echo "Error: File cadangan konfigurasi tidak ditemukan di $SNORT_CONF_BAK."
  exit 1
fi

echo "### Restart layanan Snort ###"
systemctl restart snort
if [ $? -eq 0 ]; then
  echo "Layanan Snort berhasil di-restart."
else
  echo "Error: Gagal me-restart layanan Snort."
  exit 1
fi

echo "### Proses selesai. Snort sekarang berjalan dengan konfigurasi yang dipulihkan! ###"
