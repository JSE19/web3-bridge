// SPDX-License-Identifier: MIT
pragma solidity ^0.8.3;
import {ERC_20} from "ERC_20";
import {SaveEther} from "SaveEther"

contract Saving is ERC_20, SaveEther{

    SaveEther svEth = new SaveEther();
    ERC_20 svTkn = new ERC_20();

    function saveEth(address _saver, uint256 _value){
        svEth.deposit();
    }

    function saveToken(address address _saver, uint256 _value) public {
        svTkn.transfer(msg.sender, _value);

        emit
    }
}