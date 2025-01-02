import subprocess
import datetime
import time

# Lokasi file output
output_file = "vm_resource_monitoring.txt"

# Fungsi untuk mendapatkan rata-rata CPU dan RAM selama 5 menit (300 detik)
def calculate_average():
    cpu_usage_list = []
    memory_usage_list = []

    commands = {
        "CPU Usage": "top -b -n1 | grep 'Cpu(s)' | awk '{print $2 + $4}'",  # %us + %sy
        "Memory Usage": "free -m | awk '/Mem:/ {print $3/$2 * 100}'",
    }

    start_time = time.time()
    end_time = start_time + 300  # 5 menit (300 detik)

    while time.time() < end_time:
        try:
            # Ambil data CPU
            cpu_result = subprocess.run(commands["CPU Usage"], shell=True, capture_output=True, text=True, timeout=5)
            if cpu_result.returncode == 0:
                cpu_value = cpu_result.stdout.strip()
                if cpu_value:
                    cpu_usage_list.append(float(cpu_value))

            # Ambil data RAM
            mem_result = subprocess.run(commands["Memory Usage"], shell=True, capture_output=True, text=True, timeout=5)
            if mem_result.returncode == 0:
                mem_value = mem_result.stdout.strip()
                if mem_value:
                    memory_usage_list.append(float(mem_value))
        except Exception as e:
            print(f"Error: {str(e)}")

        time.sleep(1)  # Tunggu 1 detik sebelum iterasi berikutnya

    # Hitung rata-rata
    avg_cpu = sum(cpu_usage_list) / len(cpu_usage_list) if cpu_usage_list else 0
    avg_memory = sum(memory_usage_list) / len(memory_usage_list) if memory_usage_list else 0

    return avg_cpu, avg_memory

# Fungsi untuk memantau resource pada VM sendiri selama 5 menit (300 detik)
def monitor_resources():
    commands = {
        "Disk Usage": "df -h",
    }

    with open(output_file, "w") as f:
        f.write("VM Resource Monitoring\n")
        f.write(f"Start Time: {datetime.datetime.now()}\n")
        f.write("========================================\n\n")

        f.write(f"Timestamp: {datetime.datetime.now()}\n")
        f.write("----------------------------------------\n")

        # Hitung rata-rata CPU dan RAM
        avg_cpu, avg_memory = calculate_average()
        f.write(f"Average CPU Usage (5m): {avg_cpu:.2f}%\n")
        f.write(f"Average Memory Usage (5m): {avg_memory:.2f}%\n")

        # Monitoring Disk Usage
        for desc, cmd in commands.items():
            f.write(f"---- {desc} ----\n")
            try:
                result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=10)
                if result.returncode == 0:
                    f.write(result.stdout)
                else:
                    f.write(f"Error: {result.stderr}\n")
            except Exception as e:
                f.write(f"Exception: {str(e)}\n")

        f.write("----------------------------------------\n\n")

    print(f"Monitoring selesai. Output disimpan di {output_file}")

# Jalankan monitoring selama 5 menit
monitor_resources()