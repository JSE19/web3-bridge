//SPDX-License-Identifier:MIT
// pragma solidity ^0.8.3;

// contract NumberFactory {
//     event YYY(address);
//     function registerNumber(uint _no) external {
//         bytes32 y = keccak256(abi.encodePacked(_no));
//         NumberChildren noChild = new NumberChildren{salt: y}(_no);
//         emit YYY(address(noChild));
//     }
// }

// contract NumberChildren {
//     uint ownerNumber;

//     constructor(uint _no) {
//         ownerNumber = _no;
//     }

//     function checkHash() public view returns (bytes32 r) {
//         r = keccak256(abi.encodePacked(ownerNumber));
//     }
// }

pragma solidity ^0.8.33;

contract NumberFactory {
    event YYY(address indexed child);
    error AddressZero();
    function registerNumber(uint _num) external {
        bytes32 y = keccak256(abi.encodePacked(_num));
        // NumberChildren n = new NumberChildren{salt: y}(_num);

                bytes memory bytecode = hex"6080604052348015600e575f5ffd5b506040516101ae3803806101ae8339818101604052810190602e9190606b565b805f81905550506091565b5f5ffd5b5f819050919050565b604d81603d565b81146056575f5ffd5b50565b5f815190506065816046565b92915050565b5f60208284031215607d57607c6039565b5b5f6088848285016059565b91505092915050565b6101108061009e5f395ff3fe6080604052348015600e575f5ffd5b50600436106026575f3560e01c806319483cd114602a575b5f5ffd5b60306044565b604051603b91906086565b60405180910390f35b5f5f546040516020016055919060c2565b60405160208183030381529060405280519060200120905090565b5f819050919050565b6080816070565b82525050565b5f60208201905060975f8301846079565b92915050565b5f819050919050565b5f819050919050565b60bc60b882609d565b60a6565b82525050565b5f60cb828460af565b6020820191508190509291505056fea2646970667358221220c9425e7b52f037df2bd8dd19cfbc4de9a3dd18080869576f0770ca3d8c9bd88464736f6c634300081f0033";

        
        bytes memory initCode = abi.encodePacked(bytecode, abi.encode(_num));


        address addr;
        // bytes memory byteCode = abi.encodePacked(
        //     type(NumberChildren).creationCode,
        //     abi.encode(_num)
        // );
        
        assembly {
            addr := create2(0, add(initCode, 0x20), mload(initCode), y)
        }
        if (addr == address(0)) {
            revert AddressZero();
        }
        emit YYY(addr);
    }
}

contract NumberChildren {
    uint ownerNumber;

    constructor(uint _num) {
        ownerNumber = _num;
    }

    function checkHash() public view returns (bytes32 r) {
        r = keccak256(abi.encodePacked(ownerNumber));
    }
}
