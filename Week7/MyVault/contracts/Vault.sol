//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract Vault {
    using SafeERC20 for IERC20;
    address public owner;
    address public tokenAddress;
    //string public tokenName;
    uint256 public totalLiquidity;

    mapping (address => uint) balances;

    error AddressZeroNotAllowed();
    error AmountShouldBeGreaterThan0();
    error InsufficientFunds();

    event Deposited(address indexed tokAddr, uint256 amount);
    event Withdrawn(address indexed to, uint256 amount);

    constructor(address _tokenAddress, address _owner){
        require(_tokenAddress!=address(0), AddressZeroNotAllowed());
        tokenAddress = _tokenAddress;
        owner = _owner;
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, AmountShouldBeGreaterThan0());
        IERC20(tokenAddress).approve(address(this),_amount);

        balances[msg.sender] += _amount;
        totalLiquidity +=_amount;

        IERC20(tokenAddress).safeTransferFrom(msg.sender,address(this),_amount);
        emit Deposited(tokenAddress,_amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, AmountShouldBeGreaterThan0());
        require(_amount <= balances[msg.sender], InsufficientFunds());

        balances[msg.sender] -= _amount;
        totalLiquidity -= _amount;

        IERC20(tokenAddress).safeTransfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
        
    }

    function getTotalSupply() external view returns (uint256) {
        return totalLiquidity;
    }
}