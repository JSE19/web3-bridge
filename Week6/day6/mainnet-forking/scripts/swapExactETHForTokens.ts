import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main = async ()=>{
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const TokenHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    await helpers.impersonateAccount(TokenHolder);
    const impersonatedSigner = await ethers.getSigner(TokenHolder);

    const USDC = await ethers.getContractAt("IERC20", USDCAddress, impersonatedSigner);

    //const DAI = await ethers.getContractAt("IERC20",DAIAddress, impersonatedSigner);

    const ROUTER = await ethers.getContractAt("IUniswapV2Router", UNIRouter, impersonatedSigner);

    //const amountIn = ethers.parseUnits("1000",6);
    const amountOutMin = ethers.parseUnits("1050", 6);
    const ethAmount = ethers.parseEther("1");
    const path = [WETHAddress,USDCAddress];
    const deadline = Math.floor(Date.now() / 1000)+60*10;

    //await USDC.approve(UNIRouter,amountIn);

    const usdcBalanceBefore = await USDC.balanceOf(impersonatedSigner.address);
    const ethBalBefore = await ethers.provider.getBalance(impersonatedSigner.address);

    console.log("=======Before============");
    console.log("USDC Balance Before: ", Number(usdcBalanceBefore));
    console.log("ETH Balance Before: ", Number(ethBalBefore));

    const trans = await ROUTER.swapExactETHForTokens(amountOutMin,path, impersonatedSigner.address,deadline, {value: ethAmount });

    await trans.wait();

    const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
    const ethBalAfter = await ethers.provider.getBalance(impersonatedSigner.address);

    console.log("=================After========================================");

    console.log("USDC Balance After: ", Number(usdcBalAfter));
    console.log("ETH Balance After: ", Number(ethBalAfter));

    console.log("=========Difference==========");
    const newUsdcValue = Number(usdcBalAfter - usdcBalanceBefore);
    const newWethValue = ethBalBefore - ethBalAfter;
    console.log("NEW USDC BALANCE: ", ethers.formatUnits(newUsdcValue, 6));
    console.log("NEW WETH BALANCE: ", ethers.formatEther(newWethValue));


}

main().catch((error)=>{
    console.error(error)
    process.exitCode =1;
})