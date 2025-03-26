// test/Messages.sol
// SPDX-License-Identifier: Apache 2

pragma solidity ^0.8;

import "../contracts/Messages.sol";
import "../contracts/Setters.sol";
import "../contracts/Structs.sol";
import "forge-std/Test.sol";

import {IRiscZeroVerifier} from "risc0/IRiscZeroVerifier.sol";
import {RiscZeroCheats} from "risc0/test/RiscZeroCheats.sol";

contract ExportedMessages is Messages, Setters {
    function storeGuardianSetPub(Structs.GuardianSet memory set, uint32 index) public {
        return super.storeGuardianSet(set, index);
    }

    function storeRiscZeroVerifier(IRiscZeroVerifier verifier) public {
        return super.setRiscZeroVerifier(verifier);
    }
}

contract TestMessages is Test, RiscZeroCheats {
  address constant testGuardianPub = 0xbeFA429d57cD18b7F8A4d91A2da9AB4AF05d0FBe;

  // A valid VM with one signature from the testGuardianPublic key
  bytes validVM = hex"01000000000100867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d900000003e800000001000b0000000000000000000000000000000000000000000000000000000000000eee00000000000005390faaaa";
  bytes validVMRiscZero = hex"0200000000000001049f39696c17a059e6ccabf91e11566d13ec4148e16b909150f882d9b702d1db43a2421f431550103dd49341b49f7c061b1c27007bfb050257cea7db72686b70023d184354269165e522216d6ea73f278983b4ca9449c4fa4d6f9ccbdb761d44d38757a8402848013cee1f65f2f3b08c53bf0f591b75adb3fbfe8ea478c8efbda7c8e2b8bf07a2387b364a67c13614e2b418edaf8e41e6be408be2079195cd32cbd3c35c6b0137e662fc762dbf536895d754c5161f80896d2eb7e125fd4084a6623e32ea9a2b31005cd6fdc34546d743657508cf39552e5e107014122b1f880d8ff1f658fc064a8c0279c7008dbb47dcd86dd660427960e15c5cea6e15b4798f64721d8628000003e800000001000b0000000000000000000000000000000000000000000000000000000000000eee00000000000005390faaaa";

  bytes validVM13Signers = hex"01000000000d00867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90001867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90002867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90003867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90004867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90005867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90006867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90007867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90008867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90009867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000a867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000b867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000c867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d900000003e800000001000b0000000000000000000000000000000000000000000000000000000000000eee00000000000005390faaaa";
  bytes validVM19Signers = hex"01000000001300867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90001867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90002867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90003867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90004867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90005867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90006867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90007867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90008867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90009867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000a867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000b867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000c867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000d867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000e867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d9000f867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90010867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90011867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d90012867b55fec41778414f0683e80a430b766b78801b7070f9198ded5e62f48ac7a44b379a6cf9920e42dbd06c5ebf5ec07a934a00a572aefc201e9f91c33ba766d900000003e800000001000b0000000000000000000000000000000000000000000000000000000000000eee00000000000005390faaaa";

  uint256 constant testGuardian = 93941733246223705020089879371323733820373732307041878556247502674739205313440;

  ExportedMessages messages;

  Structs.GuardianSet guardianSet;

  function setUp() public {
    messages = new ExportedMessages();

    // initialize risc0 verifier
    IRiscZeroVerifier verifier = deployRiscZeroVerifier();
    messages.storeRiscZeroVerifier(verifier);

    // initialize guardian set with one guardian
    address[] memory keys = new address[](1);
    keys[0] = vm.addr(testGuardian);
    guardianSet = Structs.GuardianSet(keys, 0);
    require(messages.quorum(guardianSet.keys.length) == 1, "Quorum should be 1");
  }

  function testQuorum() public {
    assertEq(messages.quorum(0), 1);
    assertEq(messages.quorum(1), 1);
    assertEq(messages.quorum(2), 2);
    assertEq(messages.quorum(3), 3);
    assertEq(messages.quorum(4), 3);
    assertEq(messages.quorum(5), 4);
    assertEq(messages.quorum(6), 5);
    assertEq(messages.quorum(7), 5);
    assertEq(messages.quorum(8), 6);
    assertEq(messages.quorum(9), 7);
    assertEq(messages.quorum(10), 7);
    assertEq(messages.quorum(11), 8);
    assertEq(messages.quorum(12), 9);
    assertEq(messages.quorum(19), 13);
    assertEq(messages.quorum(20), 14);
  }

  function testQuorumCanAlwaysBeReached(uint256 numGuardians) public {
    vm.assume(numGuardians > 0);

    if (numGuardians >= 256) {
      vm.expectRevert("too many guardians");
    }
    // test that quorums is never greater than the number of guardians
    assert(messages.quorum(numGuardians) <= numGuardians);
  }

  // This test ensures that submitting more signatures than expected will
  // trigger a "guardian index out of bounds" error.
  function testCannotVerifySignaturesWithOutOfBoundsSignature(bytes memory encoded) public {
    vm.assume(encoded.length > 0);

    bytes32 message = keccak256(encoded);

    // First generate a legitimate signature.
    Structs.Signature memory goodSignature = Structs.Signature(message, 0, 0, 0);
    (goodSignature.v, goodSignature.r, goodSignature.s) = vm.sign(testGuardian, message);
    assertEq(ecrecover(message, goodSignature.v, goodSignature.r, goodSignature.s), vm.addr(testGuardian));

    // Reuse legitimate signature above for the next signature. This will
    // bypass the "invalid signature" revert.
    Structs.Signature memory outOfBoundsSignature = goodSignature;
    outOfBoundsSignature.guardianIndex = 1;

    // Attempt to verify signatures.
    Structs.Signature[] memory sigs = new Structs.Signature[](2);
    sigs[0] = goodSignature;
    sigs[1] = outOfBoundsSignature;

    vm.expectRevert("guardian index out of bounds");
    messages.verifySignatures(message, sigs, guardianSet);
  }

  // This test ensures that submitting an invalid signature fails when
  // verifySignatures is called. Calling ecrecover should fail.
  function testCannotVerifySignaturesWithInvalidSignature(bytes memory encoded) public {
    vm.assume(encoded.length > 0);

    bytes32 message = keccak256(encoded);

    // Generate an invalid signature.
    Structs.Signature memory badSignature = Structs.Signature(message, 0, 0, 0);
    assertEq(ecrecover(message, badSignature.v, badSignature.r, badSignature.s), address(0));

    // Attempt to verify signatures.
    Structs.Signature[] memory sigs = new Structs.Signature[](2);
    sigs[0] = badSignature;

    vm.expectRevert("ecrecover failed with signature");
    messages.verifySignatures(message, sigs, guardianSet);
  }

  function testVerifySignatures(bytes memory encoded) public {
    vm.assume(encoded.length > 0);

    bytes32 message = keccak256(encoded);

    // Generate legitimate signature.
    Structs.Signature memory goodSignature;
    (goodSignature.v, goodSignature.r, goodSignature.s) = vm.sign(testGuardian, message);
    assertEq(ecrecover(message, goodSignature.v, goodSignature.r, goodSignature.s), vm.addr(testGuardian));
    goodSignature.guardianIndex = 0;

    // Attempt to verify signatures.
    Structs.Signature[] memory sigs = new Structs.Signature[](1);
    sigs[0] = goodSignature;

    (bool valid, string memory reason) = messages.verifySignatures(message, sigs, guardianSet);
    assertEq(valid, true);
    assertEq(bytes(reason).length, 0);
  }

  // This test checks the possibility of getting a unsigned message verified through verifyVM
  function testHashMismatchedVMIsNotVerified() public {
    // Set the initial guardian set
    address[] memory initialGuardians = new address[](1);
    initialGuardians[0] = testGuardianPub;

    // Create a guardian set
    Structs.GuardianSet memory initialGuardianSet = Structs.GuardianSet({
      keys: initialGuardians,
      expirationTime: 0
    });

    messages.storeGuardianSetPub(initialGuardianSet, uint32(0));

    // Confirm that the test VM is valid
    vm.startSnapshotGas("V1_parseAndVerifyVM");
    (Structs.VM memory parsedValidVm, bool valid, string memory reason) = messages.parseAndVerifyVM(validVM);
    vm.stopSnapshotGas();
    require(valid, reason);
    assertEq(valid, true);
    assertEq(reason, "");

    // Manipulate the payload of the vm
    Structs.VM memory invalidVm = parsedValidVm;
    invalidVm.payload = abi.encodePacked(
        parsedValidVm.payload,
        "malicious bytes in payload"
    );

    // Confirm that the verifyVM fails on invalid VM
    (valid, reason) = messages.verifyVM(invalidVm);
    assertEq(valid, false);
    assertEq(reason, "vm.hash doesn't match body");
  }

    // This test checks the possibility of getting a unsigned message verified through verifyVM
  function testRisc0AuthorizedVM() public {
    // Set the initial guardian set
    address[] memory initialGuardians = new address[](1);
    initialGuardians[0] = testGuardianPub;

    // Create a guardian set
    Structs.GuardianSet memory initialGuardianSet = Structs.GuardianSet({
      keys: initialGuardians,
      expirationTime: 0
    });

    messages.storeGuardianSetPub(initialGuardianSet, uint32(0));

    // Confirm that the test VM is valid
    vm.startSnapshotGas("V2_parseAndVerifyVM");
    (, bool valid, string memory reason) = messages.parseAndVerifyVM(validVMRiscZero);
    vm.stopSnapshotGas();

    require(valid, reason);
    assertEq(valid, true);
    assertEq(reason, "");
  }

    // This test checks the possibility of getting a unsigned message verified through verifyVM
  function testMaxSignersVm() public {
    // Set the initial guardian set
    uint maxSigners = 19;
    address[] memory initialGuardians = new address[](maxSigners);

    for (uint i = 0; i < maxSigners; i++) {
      initialGuardians[i] = testGuardianPub;
    }

    // Create a guardian set
    Structs.GuardianSet memory initialGuardianSet = Structs.GuardianSet({
      keys: initialGuardians,
      expirationTime: 0
    });

    messages.storeGuardianSetPub(initialGuardianSet, uint32(0));

    // Confirm that the test VM is valid
    vm.startSnapshotGas("V1_parseAndVerifyVMQuorum");
    (, , string memory reason13) = messages.parseAndVerifyVM(validVM13Signers);
    vm.stopSnapshotGas();

    vm.startSnapshotGas("V1_parseAndVerifyVMMax");
    (,, string memory reason19) = messages.parseAndVerifyVM(validVM19Signers);
    vm.stopSnapshotGas();
  }

  function testBodySameBetweenV1V2() public {
    Structs.VM memory v1 = messages.parseVM(validVM);
    Structs.VM memory v2 = messages.parseVM(validVMRiscZero);

    assertEq(v1.version, 1);
    assertEq(v2.version, 2);

    // Check equivalence of matching fields between v1 and v2
    assertEq(v1.guardianSetIndex, v2.guardianSetIndex);
    assertEq(v1.timestamp, v2.timestamp);
    assertEq(v1.nonce, v2.nonce);
    assertEq(v1.emitterChainId, v2.emitterChainId);
    assertEq(v1.emitterAddress, v2.emitterAddress);
    assertEq(v1.sequence, v2.sequence);
    assertEq(v1.consistencyLevel, v2.consistencyLevel);
    assertEq(v1.payload, v2.payload);


    assertEq(v1.hash, v2.hash);
  }
}
