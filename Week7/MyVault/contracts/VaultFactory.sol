//SPDX-Licennse-Identifier: MIT
pragma solidity ^0.8.3;
import {Vault} from "./Vault.sol";

contract VaultFactory {
    address[] public allVaults;
    mapping(address => address) public vaults;

    error AddressZeroNotAllowed();
    error VaultExistAlready();

    event VaultCreated(address tokenAddress, address indexed vaultAddress);

    constructor() {}

    function createVault(
        address _tokenAddress
    ) external returns (address) {
        require(_tokenAddress != address(0), AddressZeroNotAllowed());

        require(vaults[_tokenAddress] == address(0), VaultExistAlready());

        bytes32 salt = keccak256(abi.encodePacked(_tokenAddress));

        Vault vault = new Vault{salt: salt}(_tokenAddress, msg.sender);

        vaults[_tokenAddress] = address(vault);
        allVaults.push(address(vault));

        emit VaultCreated(_tokenAddress, address(vault));

        return address(vault);
    }

    function getAllVaults() external view returns (address[] memory) {
        return allVaults;
    }

    function predictAddress(address _tokenAddress)  external returns(address) {
        bytes32 salt = keccak256(abi.encodePacked(_tokenAddress));

        bytes memory byteCode = abi.encodePacked(type(Vault).creationCode, abi.encodePacked(_tokenAddress));

        return address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff),address(this),salt, keccak256(byteCode))))));

    }
}
