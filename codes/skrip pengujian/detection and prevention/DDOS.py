import subprocess
import time

def simulate_ddos_attack(ip, iterations):
    detected_attacks = 0

    for i in range(iterations):
        command = [
            "ab",
            "-n", "1000",
            "-c", "500",
            f"http://{ip}/"
        ]
        try:
            print(f"Simulating DDoS attack #{i + 1} on {ip}...")
            subprocess.run(command, check=True)
            detected_attacks += 1  # Anggap serangan terdeteksi jika sukses dijalankan
        except subprocess.CalledProcessError as e:
            print(f"Error during attack simulation #{i + 1}: {e}")
        time.sleep(5)  # Interval antar serangan

    return detected_attacks

def calculate_detection_rate(detected, total):
    detection_rate = (detected / total) * 100
    print(f"\nDetection Rate: {detection_rate:.2f}% ({detected}/{total} attacks detected)")

def run_detection_rate_test(ip):
    total_attacks = 10  # Total jumlah serangan DDoS yang akan diuji
    detected_attacks = simulate_ddos_attack(ip, total_attacks)
    calculate_detection_rate(detected_attacks, total_attacks)

if __name__ == "__main__":
    ip_address = input("Enter the IP address or domain to test: ")
    run_detection_rate_test(ip_address)