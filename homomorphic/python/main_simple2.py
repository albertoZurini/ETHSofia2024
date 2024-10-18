import random

def generate_key():
    return random.randint(2, 100)  # Choose a random key between 2 and 100

key = generate_key()

def encrypt(number):
    return number * key

def decrypt(encrypted_number):
    return encrypted_number // key

def sum(encrypted_a, encrypted_b):
    return encrypted_a + encrypted_b

# Example usage
n1 = 5
n2 = 10
n3 = 7

encrypted_n1 = encrypt(n1)
encrypted_n2 = encrypt(n2)
encrypted_n3 = encrypt(n3)

result = sum(sum(encrypted_n1, encrypted_n2), encrypted_n3)
decrypted_result = decrypt(result)

print(f"Original numbers: {n1}, {n2}, {n3}")
print(f"Sum: {decrypted_result}")
print(f"Actual sum: {n1 + n2 + n3}")