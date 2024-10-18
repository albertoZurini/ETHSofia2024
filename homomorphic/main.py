import random
import gmpy2

class PaillierHomomorphicEncryption:
    def __init__(self, bits=512):
        self.p, self.q = self.generate_prime(bits), self.generate_prime(bits)
        self.n = self.p * self.q
        self.lambda_val = self.lcm(self.p - 1, self.q - 1)
        self.g = self.n + 1  # g = n + 1 is a common choice for g
        self.n_sq = self.n * self.n
        self.mu = gmpy2.invert(self.lambda_val, self.n)  # mu = lambda^-1 mod n
        
    def generate_prime(self, bits):
        return gmpy2.next_prime(random.getrandbits(bits))

    def lcm(self, a, b):
        return (a * b) // gmpy2.gcd(a, b)

    def encrypt(self, plaintext):
        r = random.randint(1, self.n - 1)
        # Ciphertext: c = (g^m * r^n) mod n^2
        ciphertext = (gmpy2.powmod(self.g, plaintext, self.n_sq) * gmpy2.powmod(r, self.n, self.n_sq)) % self.n_sq
        return ciphertext

    def decrypt(self, ciphertext):
        # Decryption: m = L(c^lambda mod n^2) * mu mod n
        x = gmpy2.powmod(ciphertext, self.lambda_val, self.n_sq)
        plaintext = ((x - 1) // self.n) * self.mu % self.n
        return int(plaintext)
    
    def homomorphic_add(self, ciphertext1, ciphertext2):
        # Homomorphic addition: c_add = (c1 * c2) mod n^2
        return (ciphertext1 * ciphertext2) % self.n_sq


# Example usage:
paillier = PaillierHomomorphicEncryption(bits=512)

# Encrypt two values
plaintext1 = 10
plaintext2 = 15
plaintext3 = 20
ciphertext1 = paillier.encrypt(plaintext1)
ciphertext2 = paillier.encrypt(plaintext2)
ciphertext3 = paillier.encrypt(plaintext3)

# Homomorphically add the encrypted values
ciphertext_sum = paillier.homomorphic_add(ciphertext1, ciphertext2)
ciphertext_sum = paillier.homomorphic_add(ciphertext_sum, ciphertext3)

# Decrypt the sum
decrypted_sum = paillier.decrypt(ciphertext_sum)

print(f"Decrypted sum: {decrypted_sum}")  # Should output 25
