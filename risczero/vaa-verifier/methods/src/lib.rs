include!(concat!(env!("OUT_DIR"), "/methods.rs"));

#[cfg(test)]
pub mod tests {
    use super::*;
    use alloy_primitives::{address, Address};
    use common::{GuardianSet, GuestInput, VAA};
    use hex_literal::hex;
    use risc0_ethereum_contracts::encode_seal;
    use risc0_zkvm::{default_executor, default_prover, ExecutorEnv, ProverOpts, VerifierContext};

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

    #[test]
    #[ignore]
    /// Build a serialization VA with a valid seal that can be used in the contract tests
    /// Unless on a powerful x86_64 machine set the env vars
    /// BONSAI_API_URL and BONSAI_API_KEY when running the test to use the Bonsai service
    pub fn build_valid_test_va() {
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

        println!("Starting proving of the program");
        let receipt = default_prover()
            .prove_with_ctx(
                env,
                &VerifierContext::default(),
                METHOD_ELF,
                &ProverOpts::groth16(),
            )
            .unwrap()
            .receipt;

        println!("proving complete, encoding VAA");

        // Encode the seal with the selector.
        let seal = encode_seal(&receipt).unwrap();

        let mut vaa = VAA::deserialize(VALID_VM).unwrap();
        vaa.version = 2;
        vaa.signatures = vec![];
        vaa.seal = seal;

        println!("VAA: {:?}", hex::encode(vaa.serialize()));
    }
}
