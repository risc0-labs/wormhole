use std::io::{Cursor, Write};

use crate::error::{Error, Result};
use crate::guardian_set::GuardianSet;

use alloy::signers::Signature;
use byteorder::{BigEndian, WriteBytesExt};
use serde::{Deserialize, Serialize};
use sha3::Digest;

type ForeignAddress = [u8; 32];

#[derive(Serialize, Deserialize, Default, Clone)]
pub struct VAASignature {
    pub signature: Vec<u8>,
    pub guardian_index: u8,
}

#[derive(Serialize, Deserialize, Default, Clone)]
pub struct VAA {
    // Header part
    pub version: u8,
    pub guardian_set_index: u32,
    pub signatures: Vec<VAASignature>,
    // Body part
    pub timestamp: u32,
    pub nonce: u32,
    pub emitter_chain: u16,
    pub emitter_address: ForeignAddress,
    pub sequence: u64,
    pub consistency_level: u8,
    pub payload: Vec<u8>,
}

impl VAA {
    pub fn verify(&self, guardian_set: &GuardianSet) -> Result<()> {
        // Serialize the VAA body into an array of bytes.
        let body = {
            let mut v = Cursor::new(Vec::new());
            v.write_u32::<BigEndian>(self.timestamp)?;
            v.write_u32::<BigEndian>(self.nonce)?;
            v.write_u16::<BigEndian>(self.emitter_chain)?;
            v.write_all(&self.emitter_address)?;
            v.write_u64::<BigEndian>(self.sequence)?;
            v.write_u8(self.consistency_level)?;
            v.write_all(&self.payload)?;
            v.into_inner()
        };

        // Hash this body, which is expected to be the same as the hash currently stored in the
        // signature account, binding that set of signatures to this VAA.
        let body_hash: [u8; 32] = {
            let mut h = sha3::Keccak256::default();
            h.write(body.as_slice())
                .map_err(|_| Error::InvalidArgument)?;
            h.finalize().into()
        };

        for signature in self.signatures.iter() {
            let recovered_signer = Signature::from_raw(&signature.signature)?
                .recover_address_from_prehash(&body_hash.into())?;
            assert_eq!(
                recovered_signer,
                guardian_set.keys[signature.guardian_index as usize]
            );
        }

        // Count the number of signatures currently present.
        let signature_count: usize = self.signatures.len();

        // Calculate how many signatures are required to reach consensus. This calculation is in
        // expanded form to ease auditing.
        let required_consensus_count = {
            let len = guardian_set.keys.len();
            // Fixed point number transformation with one decimal to deal with rounding.
            let len = (len * 10) / 3;
            // Multiplication by two to get a 2/3 quorum.
            let len = len * 2;
            // Division to bring number back into range.
            len / 10 + 1
        };

        if signature_count < required_consensus_count {
            return Err(Error::QuorumNotMet);
        }

        Ok(())
    }
}
