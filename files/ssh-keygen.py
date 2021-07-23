import os
import sys

from cryptography.hazmat.primitives.asymmetric import rsa as pk
from cryptography.hazmat.primitives import serialization as crypto_ser


ssh_privkey_filename = sys.argv[1]
ssh_pubkey_filename = f'{ssh_privkey_filename}.pub'

print("Generating SSH Keys for BioThings Hub...")
privkey = pk.generate_private_key(65537, 2048)
with open(ssh_privkey_filename, 'wb') as f:
	f.write(
		privkey.private_bytes(
			crypto_ser.Encoding.PEM, 
			crypto_ser.PrivateFormat.OpenSSH, 
			crypto_ser.NoEncryption()
		)
	)
pubkey = privkey.public_key().public_bytes(crypto_ser.Encoding.OpenSSH, crypto_ser.PublicFormat.OpenSSH)
with open(ssh_pubkey_filename, 'wb') as f:
	f.write(pubkey)
print("SSH Key has been generated, Public Key:\n")
print(pubkey.decode('ASCII'))
print()
