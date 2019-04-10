pragma solidity 0.5.7;
import "./Verifier.sol";
import "./Counterfactual.sol";
import "./ManagedRoot.sol";

contract ZkSnarkProgenitor {
    Verifier verifier;
    ManagedRoot managedRoot;
    
    
    function init(Verifier _verifier, ManagedRoot _managedRoot) external {
        require(verifier == Verifier(0));
        verifier = _verifier;
        managedRoot = _managedRoot;
    }
    
    function deploy(bytes32 _pubId) external returns (Counterfactual counterfactual){
        bytes memory creationCode = type(Counterfactual).creationCode;
    
        // solium-disable-next-line security/no-inline-assembly
        assembly {
          counterfactual := create2(0x0, add(0x20, creationCode), mload(creationCode), _pubId)
        }
        counterfactual.init(_pubId);
    }
    
    
    function isValidSignature(bytes32 _hash, bytes32 _pubId, bytes calldata _signature) external view returns (bool output){
        (
            uint[2] memory a,
            uint[2] memory a_p,
            uint[2][2] memory b,
            uint[2] memory b_p,
            uint[2] memory c,
            uint[2] memory c_p,
            uint[2] memory h,
            uint[2] memory k,
            uint[4] memory input
        )  = abi.decode(_signature, (
            uint[2],
            uint[2],
            uint[2][2],
            uint[2],
            uint[2],
            uint[2],
            uint[2],
            uint[2],
            uint[4]
        ));
        output = (input[0] == uint(_pubId));
        output = output && (input[1] == 1);
        output = output && (input[2] == managedRoot.getRoot());
        output = output && (input[3] == uint(_hash));
        output = output && (verifier.verifyProof(a,a_p,b,b_p,c,c_p,h,k,input));
    }
}

