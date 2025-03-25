mod error;
mod guardian_set;
mod vaa;

use alloy::primitives::B256;
use alloy_sol_types::{sol, SolValue};
use serde::{Deserialize, Serialize};

pub use error::{Error, Result};
pub use guardian_set::GuardianSet;
pub use vaa::VAA;

#[derive(Serialize, Deserialize)]
pub struct GuestInput {
    pub vaa: VAA,
    pub guardian_set: GuardianSet,
}

impl GuestInput {
    pub fn encode(&self) -> Result<Vec<u8>> {
        Ok(bincode::serialize(self)?)
    }

    pub fn decode(data: &[u8]) -> Result<Self> {
        Ok(bincode::deserialize(data)?)
    }
}

sol! {
    struct Journal {
        bytes32 guardianSetHash;
        bytes32 vaaHash;
    }
}

impl Journal {
    pub fn new(guardian_set_hash: &[u8], vaa_hash: &[u8]) -> Self {
        Self {
            guardianSetHash: B256::from_slice(guardian_set_hash),
            vaaHash: B256::from_slice(vaa_hash),
        }
    }

    pub fn encode(&self) -> Vec<u8> {
        self.abi_encode()
    }
}
