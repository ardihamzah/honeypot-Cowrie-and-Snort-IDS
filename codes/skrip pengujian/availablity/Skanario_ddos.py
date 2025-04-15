import subprocess
import time

def run_ab_test(ip):
    command = [
        "ab",
        "-n", "1000",
        "-c", "1000",
        f"http://{ip}/"
    ]

    while True:
        try:
            print(f"Running ApacheBench on {ip}...")
            subprocess.run(command, check=True)
            print("ApacheBench test completed. Waiting for the next interval...")
        except subprocess.CalledProcessError as e:
            print(f"Error running ApacheBench: {e}")

        # Sleep for 10 minutes and 20 seconds (620 seconds)
        time.sleep(620)

if __name__ == "__main__":
    ip_address = input("Enter the IP address or domain to test: ")
    run_ab_test(ip_address)