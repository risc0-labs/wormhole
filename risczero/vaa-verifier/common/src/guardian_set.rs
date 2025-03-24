use serde::{Deserialize, Serialize};

/// Type representing an Ethereum style public key for Guardians.
pub type GuardianPublicKey = [u8; 20];

#[derive(Default, Serialize, Deserialize)]
pub struct GuardianSet {
    /// Index representing an incrementing version number for this guardian set.
    pub index: u32,

    /// ETH style public keys
    pub keys: Vec<GuardianPublicKey>,

    /// Timestamp representing the time this guardian became active.
    pub creation_time: u32,

    /// Expiration time when VAAs issued by this set are no longer valid.
    pub expiration_time: u32,
}

impl GuardianSet {
    pub fn commitment(&self) -> Vec<u8> {
        todo!()
    }
}
