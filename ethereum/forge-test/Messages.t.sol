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
  bytes validVMRiscZero = hex"020000000004c101b42b2dd34962f3d2e05f053e584d6fed583b2ba3df3dc7246f665f0a55e880990d430028abddc06f33e71eb286c7d24c2d59ac0fa3682edaf7bfd2b6b92d336735f100ca6b8d842a10e9bb76a52f423dde9841d32d9b71f2a59232c5c6cd109696e90bd877098e00c5012da8f8f88265de5b9cf6112383ef92268360429a6d6a05fc1904273f8f06b563cb89b08db56e9658be377ac96557250a4800d27cd30295cb0161cd5d497bb26dbb36ec3b22afdb2504d8e8dbcf466df81153b5067581e44b048529d89787978c35fae1f9a08327dde854888599d44afd9c0390a4e16b816909dc915a29fc97c7c277ededa2a620fcd2b5e36d79508fbb45ab66c2aa442cc5000003e800000001000b0000000000000000000000000000000000000000000000000000000000000eee00000000000005390faaaa";

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
    (Structs.VM memory parsedValidVm, bool valid, string memory reason) = messages.parseAndVerifyVM(validVM);
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
    (Structs.VM memory parsedValidVm, bool valid, string memory reason) = messages.parseAndVerifyVM(validVMRiscZero);
    require(valid, reason);
    assertEq(valid, true);
    assertEq(reason, "");
  }
}
