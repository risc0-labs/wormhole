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
    pub vaa_bytes: Vec<u8>,
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

#[cfg(test)]
pub mod tests {
    use super::*;
    use alloy::primitives::{address, Address};
    use hex_literal::hex;

    const TEST_GUARDIAN_PUB: Address = address!("0xbeFA429d57cD18b7F8A4d91A2da9AB4AF05d0FBe");

    // A valid VM (VAA) with one signature from the testGuardianPublic key. Taken from the solidity tests
    const VALID_VM: &'static [u8] = &hex!("01000000000100867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d900000003e800000001000b0000000000000000000000000000000000000000000000000000000000000eee00000000000005390faaaa");

    #[test]
    pub fn verify_valid_vm() {
        let guardian_set = GuardianSet {
            index: 0,
            keys: vec![TEST_GUARDIAN_PUB],
            creation_time: 0,
            expiration_time: 0,
        };
        let vaa = VAA::deserialize(VALID_VM).expect("Failed to decode VAA");
        vaa.verify(&guardian_set).expect("Failed to verify VAA");
    }
}
