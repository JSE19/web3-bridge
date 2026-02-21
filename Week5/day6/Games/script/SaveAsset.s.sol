// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {SaveAsset} from "../src/SaveAsset.sol";

contract SaveAssetScript is Script {
    SaveAsset public saveAsset;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        saveAsset = new SaveAsset(0x12Fbe72987bFf3653e84E03894EB085c760a8A0e);

        vm.stopBroadcast();
    }
}
