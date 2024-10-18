import os
import json

with open("/home/alberto/Documents/hackathon/202410_ETHSofia/zkverify/homomorphic/python/transactions.json", "r") as f:
    data = json.loads(f.read())

enc = " ".join([ str(i) for i in data["encrypted"]])

cmd = f"""cargo run --release -- {enc} {data["enc_sum"]} {data["key"]} {data["clear_sum"]} > output.txt"""
print("Executing", cmd)
os.system(cmd)

with open("/home/alberto/Documents/hackathon/202410_ETHSofia/zkverify/risc0/hasher/output.txt", "r") as f:
    data = f.read().split("\n")

proof = "0x" + data[0].replace('"', "").replace("Serialized bytes array (hex) INNER: ", "")
pubs =  "0x" + data[2].replace('"', "").replace("Serialized bytes array (hex) JOURNAL: ", "")
vk =    "0x" + data[4].replace('"', "").replace("Serialized bytes array (hex) IMAGE_ID: ", "")

json_obj = {
    "vk": vk,
    "publicSignals": pubs,
    "proof": proof
}

json_string = json.dumps(json_obj)

with open("/home/alberto/Documents/hackathon/202410_ETHSofia/zkverify/risc0/zkverify_proj/src/proofs/risc0.json", "w") as f:
    f.write(json_string)