import random
import json

class SimpleHomomorphicEncryption:
    def __init__(self, key):
        self.key = key

    def encrypt(self, plaintext):
        # Encrypt the plaintext by adding the key
        return plaintext * key

    def decrypt(self, ciphertext):
        # Decrypt the ciphertext by subtracting the key
        return ciphertext // key

    def add_encrypted(self, encrypted1, encrypted2):
        # Sum the two encrypted values
        return encrypted1 + encrypted2


def generate_key():
    return random.randint(10000, 1000000)  # Choose a random key between 2 and 100

# Example usage
if __name__ == "__main__":
    HOW_MANY = 10
    key = generate_key()  # The encryption key
    he = SimpleHomomorphicEncryption(key)

    # Original numbers
    transactions = [10, 15, 20, -10, 10]
    random.shuffle(transactions)
    cleartext_amounts = transactions
    clear_sum = sum(cleartext_amounts)

    encrypted = [he.encrypt(i) for i in cleartext_amounts]

    #enc_sum = encrypted[0]
    #for i in range(1, HOW_MANY):
    #    enc_sum = he.add_encrypted(enc_sum, encrypted[i])
    enc_sum = sum(encrypted)

    dec_sum = he.decrypt(enc_sum)

    if clear_sum == dec_sum:
        to_save = {
            "clear_sum": clear_sum,
            "encrypted": encrypted,
            "enc_sum": enc_sum,
            "key": key
        }
        
        with open("transactions.json", "w") as f:
            f.write(json.dumps(to_save))
            
        print(cleartext_amounts)
        print(to_save)
    else:
        print("Something went wrong")
