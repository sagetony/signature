// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Airdrop {
    address public owner;
    mapping(address => uint256) public balances;
    mapping(address => bool) public claimed;
    struct Signature {
        uint8 v;
        bytes32 r;
        bytes32 s;
    }
    event TokensClaimed(address indexed user, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    function claimTokens(
        uint256 amount,
        address user,
        Signature memory signatures
    ) public {
        require(!claimed[msg.sender], "Tokens already claimed");

        require(
            _verifySignature(user, amount, signatures) == user,
            "Access restricted"
        );

        balances[msg.sender] += amount;
        claimed[msg.sender] = true;

        emit TokensClaimed(msg.sender, amount);
    }

    function _verifySignature(
        address to,
        uint256 amount,
        Signature memory signature
    ) internal pure returns (address signer) {
        // 52 = message byte length
        string memory header = "\x19Ethereum Signed Message:\n52";

        bytes32 messageHash = keccak256(abi.encodePacked(header, to, amount));

        // Perform the elliptic curve recover operation
        return ecrecover(messageHash, signature.v, signature.r, signature.s);
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }
}
