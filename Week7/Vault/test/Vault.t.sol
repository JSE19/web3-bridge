
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/VaultFactory.sol";
import "../src/Vault.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract VaultFactoryTest is Test {

    VaultFactory factory;

    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address impersonator = 0xf584F8728B874a6a5c7A8d4d387C9aae9172D621;

    function setUp() public {
        vm.createSelectFork(vm.envString("MAINNET_RPC_URL"));
        factory = new VaultFactory();
    }

    function testCreateVault() public{
        deal(USDC, impersonator, 100e6);
        vm.startPrank(impersonator);
        Vault vault = Vault(factory.createVault(USDC));

        IERC20(USDC).approve(address(vault),10e6);
        vault.deposit(5e6);

        vm.stopPrank();

        assertEq(factory.getAllVaults().length,1);
        assertEq(vault.getTotalLiquity(), 5e6);

        
        console.log("Usdc Vault:", address(vault));
        console.log("NFT TOKEN: ", factory.vaultNFT().tokenURI(0));

    }

     function testDepositAndWithdraw() public {
        deal(USDC, impersonator, 100e6);
        vm.startPrank(impersonator);
        Vault vault = Vault(factory.createVault(USDC));
        
        IERC20(USDC).approve(address(vault),10e6);

        vault.deposit(5e6);
        assertEq(factory.getAllVaults().length,1);

        vault.withdraw(2e6);
        vm.stopPrank();
        assertEq(vault.getTotalLiquity(), 3e6);


     }

     function testDepositZero() public {
        deal(USDC,impersonator,10e6);
        vm.startPrank(impersonator);
        Vault vault = Vault(factory.createVault(USDC));
        
        IERC20(USDC).approve(address(vault),10e6);
        vm.expectRevert(Vault.GreaterThan0.selector);
        vault.deposit(0);
        vm.stopPrank();
        
     }
   //   function testEmitDeposited() public {
   //      deal(USDC, impersonator,10e6);
   //      Vault vault = Vault(factory.createVault(USDC));
   //      vm.startPrank(impersonator);
   //      IERC20(USDC).approve(address(vault),3e6);
   //      vm.expectEmit(true,false,false,true);
   //      emit Vault.Deposited(impersonator,2e6);
   //      vault.deposit(2e6);
   //      vm.stopPrank();

   //   }

       
}