// SPDX-License-Identifier:MIT

pragma solidity ^0.8.3;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";
import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol"; 
import {SaveEth} from "./SaveEth.sol";

contract PiggyVestNFT is ERC721{
    using Strings for uint256;
    using Strings for address;

    uint256 private _nextTokenId;
    mapping (address => uint) public ethVault;
    mapping (uint => address) public vaultEth ;

    constructor()ERC721("MYPIGGYVEST","MPV"){}

    function mint(address _to) external returns (uint256) {
        
    }

}
