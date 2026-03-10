pragma solidity ^0.8.13;

import {Test} from "forge-std/Test.sol";
import {ProofOfExistence} from "../src/ProofOfExistence.sol";

contract ProofTest is Test{
    ProofOfExistence public proofOfExistence;

    address joy = makeAddr("joy");
    address glory = makeAddr("glory");
    function setUp() public{
        proofOfExistence = new ProofOfExistence();
    }
    function testAddDoc() public {
        bytes32 myHash = keccak256("Welcome My Doc");
        vm.prank(joy);
        proofOfExistence.addDocument(myHash,"My first Doc");

        assertTrue(proofOfExistence.verifyDocumentExistence(myHash));

    }

    function testGetDocument() public{
        bytes32 myHash = keccak256("Hello");
        vm.prank(joy);
        proofOfExistence.addDocument(myHash, "My Document");

        vm.prank(joy);
        assertTrue(ProofOfExistence.getDocument());
        //ProofOfExistence.getDocument();
        
    }
}