// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SchoolPortal} from "../src/SchoolPortal.sol";

contract SchoolPortalScript is Script {
    SchoolPortal public schoolPortal;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        schoolPortal = new SchoolPortal(0x12Fbe72987bFf3653e84E03894EB085c760a8A0e);

        vm.stopBroadcast();
    }
}
