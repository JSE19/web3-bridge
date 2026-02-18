// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {StudentReg} from "../src/StudentReg.sol";

contract StudentRegScript is Script {
    StudentReg public studentReg;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        studentReg = new StudentReg();

        vm.stopBroadcast();
    }
}
