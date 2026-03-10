//SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

// import {IUniswapV2Router01} from "./IUniswapV2Router01.sol";
// import {IUniswapV2Factory} from "./IUniswapV2Factory.sol";

contract Vault {
    using SafeERC20 for IERC20;

    // uint256 public tokenAmount;
    // string public tokenName;
    address public owner;
    address public tokenAddress;
    uint256 public totalLiquidity;

    mapping(address => uint) balances;

    error AddressZeroDetected();
    error GreaterThan0();
    error InsufficientBalance();

    event Deposited(address indexed sender, uint256 amount);
    event Withdrawn(address indexed, uint256 amount);

    constructor(address _tokenAddress, address _owner) {
        require(_tokenAddress != address(0), AddressZeroDetected());
        tokenAddress = _tokenAddress;
        owner = _owner;
    }

    function deposit(uint256 _amount) external {
        require(_amount > 0, GreaterThan0());

        balances[msg.sender] = balances[msg.sender] + _amount;
        totalLiquidity = totalLiquidity + _amount;
        IERC20(tokenAddress).safeTransferFrom(
            msg.sender,
            address(this),
            _amount
        );

        emit Deposited(msg.sender, _amount);
    }

    function withdraw(uint256 _amount) external {
        require(_amount > 0, GreaterThan0());
        require(_amount <= balances[msg.sender], InsufficientBalance());

        balances[msg.sender] = balances[msg.sender] - _amount;
        totalLiquidity = totalLiquidity - _amount;

        IERC20(tokenAddress).safeTransfer(msg.sender, _amount);
        emit Withdrawn(msg.sender, _amount);
    }

    function getTotalLiquity() public view returns (uint256) {
        return totalLiquidity;
    }
}
