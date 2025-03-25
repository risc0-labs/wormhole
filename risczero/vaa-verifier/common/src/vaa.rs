use std::io::{Cursor, Read, Write};

use crate::error::{Error, Result};
use crate::guardian_set::GuardianSet;

use alloy::signers::Signature;
use byteorder::{BigEndian, ReadBytesExt, WriteBytesExt};
use sha3::Digest;

type ForeignAddress = [u8; 32];

#[derive(Default, Clone)]
pub struct VAASignature {
    pub signature: Vec<u8>,
    pub guardian_index: u8,
}

#[derive(Default, Clone)]
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
    pub const HEADER_LEN: usize = 6;
    pub const SIGNATURE_LEN: usize = 66;

    pub fn deserialize(data: &[u8]) -> std::result::Result<VAA, std::io::Error> {
        let mut rdr = Cursor::new(data);

        let version = rdr.read_u8()?;
        let guardian_set_index = rdr.read_u32::<BigEndian>()?;

        let len_sig = rdr.read_u8()?;
        let mut signatures: Vec<VAASignature> = Vec::with_capacity(len_sig as usize);
        for _i in 0..len_sig {
            let guardian_index = rdr.read_u8()?;
            let mut signature_data = [0u8; 65];
            rdr.read_exact(&mut signature_data)?;
            let signature = signature_data.to_vec();

            signatures.push(VAASignature {
                guardian_index,
                signature,
            });
        }

        let timestamp = rdr.read_u32::<BigEndian>()?;
        let nonce = rdr.read_u32::<BigEndian>()?;
        let emitter_chain = rdr.read_u16::<BigEndian>()?;

        let mut emitter_address = [0u8; 32];
        rdr.read_exact(&mut emitter_address)?;

        let sequence = rdr.read_u64::<BigEndian>()?;
        let consistency_level = rdr.read_u8()?;

        let mut payload = Vec::new();
        rdr.read_to_end(&mut payload)?;

        Ok(VAA {
            version,
            guardian_set_index,
            signatures,
            timestamp,
            nonce,
            emitter_chain,
            emitter_address,
            sequence,
            consistency_level,
            payload,
        })
    }

    pub fn verify(&self, guardian_set: &GuardianSet) -> Result<()> {
        // Hash this body
        let body_hash = self.body_hash();

        // hash the result again
        let signed_hash: [u8; 32] = {
            let mut h = sha3::Keccak256::default();
            h.write(body_hash.as_slice()).unwrap();
            h.finalize().into()
        };

        // check signatures against double hashed body
        for signature in self.signatures.iter() {
            let recovered_signer = Signature::from_raw(&signature.signature)?
                .recover_address_from_prehash(&signed_hash.into())?;
            assert_eq!(
                recovered_signer, guardian_set.keys[signature.guardian_index as usize],
                "Signature {} failed verification",
                signature.guardian_index
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

    pub fn body_hash(&self) -> [u8; 32] {
        let body = {
            let mut v = Cursor::new(Vec::new());
            v.write_u32::<BigEndian>(self.timestamp).unwrap();
            v.write_u32::<BigEndian>(self.nonce).unwrap();
            v.write_u16::<BigEndian>(self.emitter_chain).unwrap();
            v.write_all(&self.emitter_address).unwrap();
            v.write_u64::<BigEndian>(self.sequence).unwrap();
            v.write_u8(self.consistency_level).unwrap();
            v.write_all(&self.payload).unwrap();
            v.into_inner()
        };

        let mut h = sha3::Keccak256::default();
        h.write(body.as_slice()).unwrap();
        h.finalize().into()
    }
}
