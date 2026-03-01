import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main =async () =>{
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";

    const USDCHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";
    // const WETHAddress = "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const amtTknDesired = ethers.parseUnits("1000",6);
    const amtTknMin= ethers.parseUnits("800",6);
    const amtETHMin =ethers.parseEther("1");
    
    const deadline = Math.floor(Date.now()/1000)+60*10;

    await helpers.impersonateAccount(USDCHolder);
    await helpers.setBalance(USDCHolder, ethers.parseEther("3"));
    const impersonatedSigner =await ethers.getSigner(USDCHolder);

    const USDC = await ethers.getContractAt("IERC20",USDCAddress,impersonatedSigner);

    const ROUTER = await ethers.getContractAt("IUniswapV2Router", UNIRouter,impersonatedSigner);

    await USDC.approve(UNIRouter, amtTknDesired);

    const usdcBalanceBefore = await USDC.balanceOf(impersonatedSigner.address);
    const ethBalanceBefore= await ethers.provider.getBalance(impersonatedSigner.address);

     console.log("=================Before========================================",
  );
  console.log("USDC Balance Before: ", ethers.formatUnits(usdcBalanceBefore),6);
  console.log("ETH Balance Before", ethers.formatEther(ethBalanceBefore))

  const trans = await ROUTER.addLiquidityETH(USDCAddress, amtTknDesired,amtTknMin, amtETHMin, impersonatedSigner.address, deadline,{value: ethers.parseEther("1")});

  await trans.wait();
  console.log("===========AFTER===============");
  const usdcBalanceAfter =await USDC.balanceOf(impersonatedSigner.address);
  const ethBalanceAfter = await ethers.provider.getBalance(impersonatedSigner.address);
  console.log("USDC Balance After: ",ethers.formatUnits(usdcBalanceAfter,6));
  console.log("ETH Balance After: ", ethers.formatEther(ethBalanceAfter));

  console.log("ETH Spent: ", ethers.formatUnits(ethBalanceBefore - ethBalanceAfter));
  console.log("USDC Spent: " , ethers.formatUnits(usdcBalanceBefore - usdcBalanceAfter))
};



main().catch((error)=>{
    console.error(error);
    process.exitCode =1;
})

// address token,
//         uint amountTokenDesired,
//         uint amountTokenMin,
//         uint amountETHMin,
//         address to,
//         uint deadline