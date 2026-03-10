import {ethers} from "hardhat";
const helpers = require("@nomicfoundation/hardhat-network-helpers");

const main = async ()=>{
    //NEEDED ADDRESSES
    const thresHoldAddress = "0xCdF7028ceAB81fA0C6971208e83fa7872994beE5";
    const shibaInuAddress = "0x95aD61b0a150d79219dCF64E1E6Cc01f0B64C4cE";
    const impersonatorAddress = "0xF977814e90dA44bFA03b6295A0616a897441aceC";
    const uniRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
    

    //STEP TO IMPERSONATE AN ADDRESS IN THE MAINNET
    await helpers.impersonateAccount(impersonatorAddress);
    const signer = await ethers.getSigner(impersonatorAddress);

    //CREATING INSTANCES OF THE CONTRACTS
    const threshHoldContract = await ethers.getContractAt("IERC20", thresHoldAddress,signer);
    const shibaInuContract = await ethers.getContractAt("IERC20",shibaInuAddress,signer);
    const Router = await ethers.getContractAt("IUniswapV2Router01",uniRouter,signer);

    //CHECK BALANCES OF IMPERSONATOR

    console.log ("---------------------CHECK BALANCES ---------------------");

    const thresHoldBalance = await threshHoldContract.balanceOf(impersonatorAddress);
    const shibainuBalance = await shibaInuContract.balanceOf(impersonatorAddress);

    console.log("ThresHold Balance: ", ethers.formatUnits(thresHoldBalance,18));
    console.log("Shiba Inu Balance: ", ethers.formatUnits(shibainuBalance,18));

    const factoryAddress = await Router.factory();
    //console.log(factoryAddress)

    const FactoryContract = await ethers.getContractAt("IUniswapV2Factory", factoryAddress, signer);

    await FactoryContract.createPair(thresHoldAddress,shibaInuAddress)

    const pairAddress = await FactoryContract.getPair(thresHoldAddress,shibaInuAddress);
    console.log(pairAddress);

    const pairContract = await ethers.getContractAt("IERC20", pairAddress, signer);
    console.log( await pairContract.balanceOf(impersonatorAddress));

    const amountADesired = ethers.parseUnits("10",18);
    const amountBDesired = ethers.parseUnits("100",18);

    const amountAMin = ethers.parseUnits("5",18);
    const amountBMin = ethers.parseUnits("50",18);
    const deadline = Math.floor(Date.now()/1000) + 60*10;
    
    (await threshHoldContract.approve(uniRouter,amountADesired)).wait;
    (await shibaInuContract.approve(uniRouter,amountBDesired)).wait;

    const trans = await Router.addLiquidity(thresHoldAddress,shibaInuAddress,amountADesired,amountBDesired,amountAMin,amountBMin,impersonatorAddress,deadline);

    await trans.wait();

    console.log("----------------------AFTER BALANCES------------------------");

    const thresHoldBalanceAfter = await threshHoldContract.balanceOf(impersonatorAddress);
    const shibainuBalanceAfter = await shibaInuContract.balanceOf(impersonatorAddress);
    const pairBalance = await pairContract.balanceOf(impersonatorAddress);

    console.log("THRESHOLD BALANCE AFTER: " , ethers.formatUnits(thresHoldBalanceAfter,18));
    console.log("SHIBAINU BALANCE AFTER: ", ethers.formatUnits(shibainuBalanceAfter,18));
    console.log("POOL BALANCE: ", ethers.formatUnits(pairBalance,18));

    console.log("ALLOWANCE",await pairContract.allowance(impersonatorAddress, uniRouter));

    const liquidityTakenOut = ethers.parseUnits("20",18);
    (await pairContract.approve(uniRouter,liquidityTakenOut)).wait;

    console.log("ALLOWANCE AFTER APPROVAL",await pairContract.allowance(impersonatorAddress, uniRouter));
    console.log("TOTAL SUPPLY: ", await pairContract.totalSupply());

    const transRemove = await Router.removeLiquidity(thresHoldAddress,shibaInuAddress,liquidityTakenOut,amountAMin,amountBMin,impersonatorAddress,deadline);

    await transRemove.wait();

    console.log("---------------------BALANCES AFTER LIQUIDITY REMOVAL-----------------------");

     const thresHoldBalanceAfterLiqRemoval = await threshHoldContract.balanceOf(impersonatorAddress);
    const shibainuBalanceAfterLiqRemoval = await shibaInuContract.balanceOf(impersonatorAddress);
    const pairBalanceLiqRemoval = await pairContract.balanceOf(impersonatorAddress);

    console.log("THRESHOLD BALANCE AFTER: " , ethers.formatUnits(thresHoldBalanceAfterLiqRemoval,18));
    console.log("SHIBAINU BALANCE AFTER: ", ethers.formatUnits(shibainuBalanceAfterLiqRemoval,18));
    console.log("POOL BALANCE: ", ethers.formatUnits(pairBalanceLiqRemoval,18));





}
main().catch((error)=>{
    console.error(error);
    process.exitCode = 1;
})