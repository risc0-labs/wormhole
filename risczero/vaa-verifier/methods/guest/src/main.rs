use common::{GuestInput, Journal};
use risc0_zkvm::guest::env;

fn main() {
    let input_data = env::read_frame();
    let input = GuestInput::decode(&input_data).expect("malformed input");

    input
        .vaa
        .verify(&input.guardian_set)
        .expect("Message not valid");

    let journal = Journal::new(&input.guardian_set.commitment(), &input.vaa.body_hash());
    env::commit_slice(&journal.encode());
}
