// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {Portal} from "../src/Portal.sol";

contract PortalScript is Script {
    Portal public schoolPortal;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        schoolPortal = new Portal(0x12Fbe72987bFf3653e84E03894EB085c760a8A0e);

        vm.stopBroadcast();
    }
}
