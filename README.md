# ZKLauren

I created a modular system that uses zero-knowledge proofs to certify the tax statements of companies. The system works by leveraging an oracle network (Blocksense) to perform currency conversions in a trusted manner. I use the oracle both to obtain current currency conversion rates and to store a private key for computing a signature, ensuring that the output values provided by the network can be trusted by the ZKP, which is the next step.

The ZKP is performed using the homomorphic properties of the account balances. I encrypt these balances so the government only knows the total amount of money transferred (since taxes are based on income) and can infer that I have more than one account (currently supporting up to five accounts). The government cannot read individual account values, but thanks to the chosen homomorphism, additions can still be performed, allowing some calculations and verification of the zero-knowledge proof.

Once the proof is generated, the government verifies it and allows me to pay the taxes.

# ISO-like documentation for SEEBLOCKS

Please open `ISO.md`.

# How the project aligns with UN17 (Blockchain for Good Alliance)

Please open `UN17.md`

# Steps to generate the signature

1. Into homomorphic generate the transactions list
2. into risc0 generate the rust code, compile it
3. run `pipeline.py` to prepare the zkverify webapp
4. run the web app to verify the signature on-chain