// These constants represent the RISC-V ELF and the image ID generated by risc0-build.
// The ELF is used for proving and the ID is used for verification.
use methods::{
    HASHER_GUEST_ELF, HASHER_GUEST_ID
};
use risc0_zkvm::{default_prover, ExecutorEnv};

fn main() {
    // Initialize tracing. In order to view logs, run `RUST_LOG=info cargo run`
    tracing_subscriber::fmt()
        .with_env_filter(tracing_subscriber::filter::EnvFilter::from_default_env())
        .init();

    // An executor environment describes the configurations for the zkVM
    // including program inputs.
    // An default ExecutorEnv can be created like so:
    // `let env = ExecutorEnv::builder().build().unwrap();`
    // However, this `env` does not have any inputs.
    //
    // To add guest input to the executor environment, use
    // ExecutorEnvBuilder::write().
    // To access this method, you'll need to use ExecutorEnv::builder(), which
    // creates an ExecutorEnvBuilder. When you're done adding input, call
    // ExecutorEnvBuilder::build().

    // For example:
    // let input: u32 = 15 * u32::pow(2, 27) + 1;
    let input: String = std::env::args().nth(1).unwrap();
    println!("Input argument is: {}", input);

    let env = ExecutorEnv::builder()
        .write(&input)
        .unwrap()
        .build()
        .unwrap();

    // Obtain the default prover.
    let prover = default_prover();

    // Proof information by proving the specified ELF binary.
    // This struct contains the receipt along with statistics about execution of the guest
    let prove_info = prover
        .prove(env, HASHER_GUEST_ELF)
        .unwrap();

    // extract the receipt.
    let receipt = prove_info.receipt;

    // TODO: Implement code for retrieving receipt journal here.

    // For example:
    // let _output: u32 = receipt.journal.decode().unwrap();
    let receipt_inner_bytes_array = bincode::serialize(&receipt.inner).unwrap();
    println!(
        "Serialized bytes array (hex) INNER: {:?}\n",
        hex::encode(&receipt_inner_bytes_array)
    );
    let receipt_journal_bytes_array = bincode::serialize(&receipt.journal).unwrap();
    println!(
        "Serialized bytes array (hex) JOURNAL: {:?}\n",
        hex::encode(&receipt_journal_bytes_array)
    );
    let mut image_id_hex = String::new();
    for &value in &HASHER_GUEST_ID {
        image_id_hex.push_str(&format!("{:08x}", value.to_be()));
    }
    println!("Serialized bytes array (hex) IMAGE_ID: {:?}\n", image_id_hex);
    let output: String = receipt.journal.decode().unwrap();
    println!("Output is: {}", output);

    // The receipt was verified at the end of proving, but the below code is an
    // example of how someone else could verify this receipt.
    receipt
        .verify(HASHER_GUEST_ID)
        .unwrap();
}
