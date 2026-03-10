//SPDX-Licennse-Identifier: MIT
pragma solidity ^0.8.3;
import {Vault} from './Vault.sol';
import {VaultNFT} from './VaultNFT.sol';

contract VaultFactory{
    VaultNFT public vaultNFT;
    address[] allVaults;
    mapping (address => address) vaults;

    error AddressZeroDetected();
    event VaultCreated(address indexed vaultAddress, address indexed tokenAddress);

    constructor() {
        vaultNFT = new VaultNFT(address(this));
    }

    function createVault(address _tokenAddress) external returns(address){
        require(_tokenAddress != address(0), AddressZeroDetected());
        bytes32 salt = keccak256(abi.encodePacked(_tokenAddress));   

        Vault vault = new Vault{salt: salt}(_tokenAddress,msg.sender);
        vaults[_tokenAddress] = address(vault);
        allVaults.push(address(vault));

        vaultNFT.mint(msg.sender, address(vault));

        emit VaultCreated(address(vault), _tokenAddress);

        return address(vault);
    }

    function getAllVaults() public view returns (address[] memory) {
        return allVaults;
    }
}