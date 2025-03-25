use common::{GuestInput, Journal, VAA};
use risc0_zkvm::guest::env;

fn main() {
    let input_data = env::read_frame();
    let input = GuestInput::decode(&input_data).expect("malformed input");

    let vaa = VAA::deserialize(&input.vaa_bytes).expect("Failed to decode VAA");
    vaa.verify(&input.guardian_set).expect("Message not valid");

    let journal = Journal::new(&input.guardian_set.commitment(), &vaa.body_hash());
    env::commit_slice(&journal.encode());
}
