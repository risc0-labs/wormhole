mod error;
mod guardian_set;
mod vaa;

use guardian_set::GuardianSet;
use serde::{Deserialize, Serialize};

pub use vaa::VAA;

#[derive(Serialize, Deserialize)]
pub struct GuestInput {
    pub vaa: VAA,
    pub guardian_set: GuardianSet,
}

pub struct Journal {
    pub guardian_set_hash: [u8; 32],
    pub vm_hash: [u8; 32],
}
