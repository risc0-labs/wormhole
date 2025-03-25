use alloy::primitives::Address;
use alloy::sol_types::SolValue;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};

#[derive(Default, Serialize, Deserialize)]
pub struct GuardianSet {
    /// Index representing an incrementing version number for this guardian set.
    pub index: u32,

    /// ETH style public keys
    pub keys: Vec<Address>,

    /// Timestamp representing the time this guardian became active.
    pub creation_time: u32,

    /// Expiration time when VAAs issued by this set are no longer valid.
    pub expiration_time: u32,
}

impl GuardianSet {
    pub fn commitment(&self) -> Vec<u8> {
        let data = self.keys.abi_encode_packed();
        let mut hasher = Sha256::new();
        hasher.update(&data);
        hasher.finalize().to_vec()
    }
}
