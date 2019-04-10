pragma solidity 0.5.7;

interface Progenitor {
    function isValidSignature(bytes32 hash, bytes32 pubId, bytes calldata signature) external view returns (bool);
}

contract Counterfactual {
    
    mapping (bytes32 => bool) public isPresigned;
    uint256 nonce;
    Progenitor progenitor;
    bytes32 pubId;
    

    event Execute(address indexed sender, address indexed target, uint256 ethValue, bytes data);
    event PresignHash(address indexed sender, bytes32 indexed hash);
    
    
    function init(bytes32 _pubId) external {
        require(progenitor == Progenitor(0));
        progenitor = Progenitor(msg.sender);
        pubId = _pubId;
    }

    function execute(address payable _target, uint256 _ethValue, bytes calldata _data, bytes calldata _signature)
        external returns (bytes memory) 
    {
        require(isValidSignature(keccak256(abi.encodePacked(_target,_ethValue,_data,nonce)), _signature));
        nonce++;
        
        (bool success, bytes memory result) = _target.call.value(_ethValue)(_data);
        require(success);
        return result;
    }

    function presignHash(bytes32 _hash, bytes calldata _signature)
        external
    {
        require(isValidSignature(_hash, _signature));
        isPresigned[_hash] = true;

        emit PresignHash(msg.sender, _hash);
    }

    function isValidSignature(bytes memory _data, bytes memory _signature) public view returns (bool) {
        return isValidSignature(keccak256(_data), _signature);
    }

    function isValidSignature(bytes32 _hash, bytes memory _signature) public view returns (bool) {
        return progenitor.isValidSignature(_hash, pubId, _signature);
    }
}
