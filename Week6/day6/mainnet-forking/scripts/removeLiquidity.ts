import { ethers } from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main = async ()=>{
    const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
    const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";
    const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    const USDCHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";

    const liquidAmt = ethers.parseUnits("300",18);
    const usdcMin = ethers.parseUnits("200",6); 
    const daiMin = ethers.parseUnits("200",18);
    const deadline = Math.floor(Date.now() / 1000)+ 60*10;

    await helpers.impersonateAccount(USDCHolder);
    const impersonatedSigner = await ethers.getSigner(USDCHolder);

    const USDC = await ethers.getContractAt("IERC20", USDCAddress, impersonatedSigner);
}
main().catch((error)=>{
    console.error(error);
    process.exitCode = 1;
})