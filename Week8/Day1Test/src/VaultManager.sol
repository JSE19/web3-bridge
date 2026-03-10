// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract VaultManager {
    mapping(address => uint256) public balances;
    uint256 public totalVaultValue;

    bool public paused;
    address[] public owners;
    mapping(address => bool) public isOwner;

    
    bool private _locked;

    error NotOwner();
    error Paused();
    error InsufficientBalance();
    error AddressZero();
    error NoOwners();
    error Reentrant();

    event Deposit(address indexed depositor, uint256 amount);
    event Withdrawal(address indexed withdrawer, uint256 amount);

    modifier onlyOwner() {
        require(isOwner[msg.sender], NotOwner());
        _;
    }

    modifier nonReentrant() {
        require(!_locked, Reentrant());
        _locked = true;
        _;
        _locked = false;
    }

    modifier whenNotPaused() {
        require(!paused, Paused());
        _;
    }

    receive() external payable {
        balances[msg.sender] += msg.value;
        totalVaultValue += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function deposit() external payable {
        balances[msg.sender] += msg.value;
        totalVaultValue += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function withdraw(uint256 amount) external whenNotPaused nonReentrant {
        require(balances[msg.sender] >= amount, InsufficientBalance());

        balances[msg.sender] -= amount;
        totalVaultValue -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }


    function emergencyWithdrawAll() external onlyOwner nonReentrant {
        uint256 amount = address(this).balance;
        require(amount > 0, InsufficientBalance());

        totalVaultValue = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Transfer failed");

        emit Withdrawal(msg.sender, amount);
    }
}
