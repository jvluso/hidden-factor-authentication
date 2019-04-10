pragma solidity ^0.5.7;


contract ManagedRoot {
    uint256 root;
    address owner;
    function setOwner(address newOwner) public {
        require(msg.sender == owner || owner == address(0));
        owner = newOwner;
    }
    function setRoot(uint256 newRoot) public {
        require(msg.sender == owner);
        root = newRoot;
    }
    function getRoot() view public returns (uint256 r) {
        return root;
    }
}



