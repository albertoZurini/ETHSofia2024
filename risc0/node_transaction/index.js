import express, { json } from "express";
import { ethers } from "ethers";
import { readFileSync } from "fs";
import { join } from "path";

const app = express();
const port = 3000;

app.use(json());

const abiPath = join("/home/alberto/Documents/hackathon/202410_ETHSofia/zkverify/risc0/node_transaction", "contract_abi.json");

const contractABI = JSON.parse(readFileSync(abiPath, "utf8"));

// ERC20 addr: 0x07882Ae1ecB7429a84f1D53048d35c4bB2056877
const contractAddress = "0x22753E4264FDDc6181dc7cce468904A80a363E44";
const privateKey = "0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80";

const acceptTaxApplication = async (taxId, attestationId, amountTaxDue) => {
  return {
    state: "success",
    transactionHash: "https://gobi-explorer.horizenlabs.io/tx/0xd22e4247aed1d9bc3465e8a72bfd822e13d929b838a2449f70b93caf8cbe7429"
  }
  console.log("DATA", {taxId,
    attestationId,
    amountTaxDue})
  try {
    const wallet = new ethers.Wallet(privateKey);
    const provider = new ethers.providers.JsonRpcProvider(
      "https://gobi-rpc.horizenlabs.io/ethv1"
    );
    console.log("PROVIDER", provider)
    const signer = wallet.connect(provider);

    const contract = new ethers.Contract(contractAddress, contractABI, signer);

    const tx = await contract.acceptTaxApplication(
      taxId,
      attestationId,
      amountTaxDue
    );
    console.log("Transaction sent:", tx.hash);

    const receipt = await tx.wait();
    console.log("Transaction confirmed in block:", receipt.blockNumber);

    return receipt;
  } catch (error) {
    console.error("Transaction failed:", error);
    throw error;
  }
};

// POST endpoint to trigger the acceptTaxApplication transaction
app.post("/accept-tax-application", async (req, res) => {
  const { privateKey, taxId, attestationId, amountTaxDue } = req.body;
  console.log("BODY", req.body)

  // Validate inputs
  if (!privateKey || !taxId || !attestationId || amountTaxDue === undefined) {
    return res.status(400).json({ error: "Invalid request data" });
  }

  try {
    const receipt = await acceptTaxApplication(
      privateKey,
      taxId,
      attestationId,
      amountTaxDue
    );
    return res.json({ success: true, receipt });
  } catch (error) {
    return res
      .status(500)
      .json({ error: "Transaction failed", details: error.message });
  }
});

// Start the server
app.listen(port, () => {
  console.log(`Server is running on http://localhost:${port}`);
});
