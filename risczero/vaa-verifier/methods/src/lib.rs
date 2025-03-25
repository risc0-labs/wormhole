include!(concat!(env!("OUT_DIR"), "/methods.rs"));

#[cfg(test)]
pub mod tests {
    use super::*;
    use alloy_primitives::{address, Address};
    use common::{GuardianSet, GuestInput};
    use hex_literal::hex;
    use risc0_zkvm::{default_executor, ExecutorEnv};

    const TEST_GUARDIAN_PUB: Address = address!("0xbeFA429d57cD18b7F8A4d91A2da9AB4AF05d0FBe");

    // A valid VM (VAA) with one signature from the testGuardianPublic key. Taken from the solidity tests
    const VALID_VM: &'static [u8] = &hex!("01000000000100867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d900000003e800000001000b0000000000000000000000000000000000000000000000000000000000000eee00000000000005390faaaa");

    #[test]
    pub fn verify_valid_vm_in_zkvm() {
        let guardian_set = GuardianSet {
            index: 0,
            keys: vec![TEST_GUARDIAN_PUB],
            creation_time: 0,
            expiration_time: 0,
        };

        let input = GuestInput {
            vaa_bytes: VALID_VM.to_vec(),
            guardian_set,
        };

        let env = ExecutorEnv::builder()
            .write_frame(&input.encode().unwrap())
            .build()
            .unwrap();

        println!("Starting execution of the program");
        let session_info = default_executor().execute(env, super::METHOD_ELF).unwrap();
        println!("program execution returned: {:?}", session_info.journal);
        println!("total cycles: {}", session_info.cycles());
    }
}
