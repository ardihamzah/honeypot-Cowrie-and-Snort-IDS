import itertools


def generate_wordlist(output_file, max_words, charset, min_length, max_length):
    with open(output_file, 'w') as f:
        count = 0
        for length in range(min_length, max_length + 1):
            for word in itertools.product(charset, repeat=length):
                if count >= max_words:
                    return
                f.write(''.join(word) + '\n')
                count += 1


# Set konfigurasi wordlist
charset = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()'
min_length = 5  # Panjang minimum kata
max_length = 8  # Panjang maksimum kata

# Membuat tiga file wordlist dengan jumlah kata yang berbeda
generate_wordlist('wordlist_399.txt', 399, charset, min_length, max_length)
generate_wordlist('wordlist_799.txt', 799, charset, min_length, max_length)
generate_wordlist('wordlist_1200.txt', 1199, charset, min_length, max_length)

print("Wordlist telah berhasil dibuat.")
