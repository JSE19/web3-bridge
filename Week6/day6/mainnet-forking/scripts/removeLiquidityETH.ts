import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");
import {main as addLiquidityETH} from './addLiquidityETH';

const main = async ()=>{
    /*  address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline */
    
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const UniRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const ImpersonatorAddress = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    await helpers.impersonateAccount(ImpersonatorAddress);
    const signer = await ethers.getSigner(ImpersonatorAddress);

    const USDCContract = ethers.getContractAt("IERC20", USDCAddress, signer);
    const Router =ethers.getContractAt("IUniswapV2Router", UniRouter,signer);

    const factoryAddress = "0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f";
    const factoryContract = await ethers.getContractAt("IUniswapV2Factory",factoryAddress,signer);
    const pairAddress = await factoryContract.getPair(USDCAddress,WETHAddress);

    const pairBalance = await ethers.provider.getBalance(pairAddress);

    const USDCBalance = (await USDCContract).balanceOf(ImpersonatorAddress);
    console.log("--------------------BEFORE ADDING LIQUIDITY-----------------");
    // console.log(await USDCContract.balanceOf(ImpersonatorAddress));
    console.log(await ethers.provider.getBalance(ImpersonatorAddress));

    await addLiquidityETH();

    console.log("--------------------AFTER ADDING LIQUIDITY-----------------");
    // console.log(await USDCContract.balanceOf(ImpersonatorAddress));
    console.log(await ethers.provider.getBalance(ImpersonatorAddress));

    

}
main().catch((error)=>{
    console.error(error);
    process.exitCode = 1;
})