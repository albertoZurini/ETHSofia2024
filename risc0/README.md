# Guides
- https://dev.risczero.com/api/zkvm/install#install (Just run `build.sh` for this)
- https://docs.zkverify.io/tutorials/run-a-zkrollup/risc0_installation/ 

Run `cargo build --release` and `cargo run --release -- "zkVerify is da best!" > output.txt` to generate the proofs.

Finally you need to save the following items:

- The serialized proof (receipt_inner_bytes_array).
- The serialized outputs (receipt_journal_bytes_array). Those are the public inputs
- The guest program fingerprint, known as image id (image_id_hex). Is the VK


