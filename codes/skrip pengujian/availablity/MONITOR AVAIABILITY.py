import requests
import time
from datetime import datetime
import re

def check_website_availability(url):
    try:
        start_time = time.time()
        response = requests.get(url, timeout=10)
        response_time = time.time() - start_time
        if response.status_code == 200:
            return True, response_time
        else:
            return False, response_time
    except requests.RequestException:
        return False, None

def is_valid_ip(ip):
    pattern = r"^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$"
    return re.match(pattern, ip) is not None

def monitor_website(ip, interval=60, output_file="website_availability_log.txt"):
    url = f"http://{ip}"
    with open(output_file, "w") as file:
        file.write(f"Monitoring Website: {url}\n")
        file.write(f"Start Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
        file.write("\n")
        file.write("Time, Status, Response Time (s)\n")
    
    while True:
        current_time = datetime.now().strftime('%Y-%m-%d %H:%M:%S')
        is_up, response_time = check_website_availability(url)
        
        if is_up:
            status = "UP"
        else:
            status = "DOWN"
            response_time = "-"
        
        log_entry = f"{current_time}, {status}, {response_time}\n"
        
        with open(output_file, "a") as file:
            file.write(log_entry)
        
        print(log_entry.strip())
        
        time.sleep(interval)

if __name__ == "__main__":
    ip_address = input("Masukkan IP address website: ").strip()
    
    if not is_valid_ip(ip_address):
        print("IP address tidak valid!")
    else:
        interval_seconds = int(input("Masukkan interval pengecekan (detik): "))
        log_file = input("Masukkan nama file log (default: website_availability_log.txt): ").strip()
        
        if not log_file:
            log_file = "website_availability_log.txt"
        
        print(f"Mulai memonitor {ip_address} setiap {interval_seconds} detik. Hasil akan disimpan di {log_file}.")
        try:
            monitor_website(ip_address, interval_seconds, log_file)
        except KeyboardInterrupt:
            print("\nMonitoring dihentikan oleh pengguna.")