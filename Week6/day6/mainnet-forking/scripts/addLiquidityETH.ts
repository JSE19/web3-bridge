import {ethers} from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

export const main = async () =>{
    
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const UniRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const ImpersonatorAddress = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    await helpers.impersonateAccount(ImpersonatorAddress);
    const signer = await ethers.getSigner(ImpersonatorAddress);

    const USDCContract = await ethers.getContractAt("IERC20", USDCAddress,signer);
    const Router = await ethers.getContractAt("IUniswapV2Router", UniRouter,signer);

    const USDCBalance = await USDCContract.balanceOf(ImpersonatorAddress);
    const ETHBalance = await ethers.provider.getBalance(ImpersonatorAddress);

    console.log("------------------BALANCES BEFORE ADDING TO LIQUIDITY-------------------");
    console.log("USDC Balance: ", ethers.formatUnits(USDCBalance,6));
    console.log("ETH Balance: ", ethers.formatEther(ETHBalance));

    /*  address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline */

    const amountUSDCDesired = ethers.parseUnits("1000",6);
    const amountUSDCMin = 0;
    const amountETHMin = 0;
    const deadline = Math.floor(Date.now()/1000)+ 60*10;

    await USDCContract.approve(UniRouter,amountUSDCDesired);

    const trans = await Router.addLiquidityETH(USDCAddress,amountUSDCDesired,amountUSDCMin,amountETHMin,ImpersonatorAddress,deadline,{value: ethers.parseEther("2")});

    await trans.wait();

    console.log("-------------AFTER LIQUIDITY---------------");
    const USDCBalanceAfter = await USDCContract.balanceOf(ImpersonatorAddress);
    const ETHBalanceAfter = await ethers.provider.getBalance(ImpersonatorAddress);
    const poolAddress = "0xB4e16d0168e52d35CaCD2c6185b44281Ec28C9Dc";

    console.log("USDC Balance: ", ethers.formatUnits(USDCBalanceAfter,6));
    console.log("ETH Balance",ethers.formatEther(ETHBalanceAfter));

}
// main().catch((error)=>{
//     console.error(error);
//     process.exitCode =  1;
// });