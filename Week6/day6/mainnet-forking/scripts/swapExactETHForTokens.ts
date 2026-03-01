import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main = async ()=>{
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const USDCHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    await helpers.impersonateAccount(USDCHolder);
    const impersonatedSigner = await ethers.getSigner(USDCHolder);

    const USDC = await ethers.getContractAt("IERC20", USDCAddress, impersonatedSigner);

    const DAI = await ethers.getContractAt("IERC20",DAIAddress, impersonatedSigner);

    const ROUTER = await ethers.getContractAt("IUniswapV2Router", UNIRouter, impersonatedSigner);

    const amountIn = ethers.parseUnits("1000",6);
    const amountOutMin = ethers.parseUnits("900",18);
    const path = [USDCAddress, DAIAddress];
    const deadline = Math.floor(Date.now() / 1000)+60*10;

    await USDC.approve(UNIRouter,amountIn);

    const usdcBalanceBefore = await USDC.balanceOf(impersonatedSigner.address);
    const daiBalBefore = await DAI.balanceOf(impersonatedSigner.address);

    console.log("=======Before============");
    console.log("USDC Balance Before: ", Number(usdcBalanceBefore));
    console.log("DAI Balance Before: ", Number(daiBalBefore));

    const trans = await ROUTER.swapExactTokensForTokens(amountIn,amountOutMin,path, impersonatedSigner.address,deadline);

    await trans.wait();

    const usdcBalAfter = await USDC.balanceOf(impersonatedSigner.address);
    const daiBalAfter = await DAI.balanceOf(impersonatedSigner.address);

    console.log("=================After========================================");

    console.log("USDC Balance After: ", Number(usdcBalAfter));
    console.log("DAI Balance After: ", Number(daiBalAfter));


}

main().catch((error)=>{
    console.error(error)
    process.exitCode =1;
})