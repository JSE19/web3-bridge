//SPX-License-Identifier: MIT
pragma solidity ^0.8.3;

import {Test} from "forge-std/Test.sol";
import "../src/SaveEth.sol";

contract SaveEthTest is Test{
    SaveEth public saveEth;

    function setUp() public{
        saveEth = new SaveEth(); 
    }

    function testDeposit() public  {

        vm.prank(msg.sender);
        saveEth.deposit{value: 4 ether}(6, "Vacation");
        assertEq(saveEth.getTotalSaves(), 4 ether);
        
    }
}