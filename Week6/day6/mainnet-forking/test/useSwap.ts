import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

const UNIRouter = "0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D";
const USDCAddress = "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48";
const DAIAddress = "0x6B175474E89094C44Da98b954EedeAC495271d0F";

const TokenHolder = "0xf584f8728b874a6a5c7a8d4d387c9aae9172d621";


describe("UniSwap", function () {
  async function deployUniswapFixtures() {
    await hre.network.provider.request({
      method: "hardhat_impersonateAccount",
      params: [TokenHolder],
    });
    const tokenHolder = await hre.ethers.getSigner(TokenHolder);

    const USDC = await hre.ethers.getContractAt("IERC20", USDCAddress, tokenHolder);
    const DAI = await hre.ethers.getContractAt("IERC20", DAIAddress, tokenHolder);
    const UniRouter = await hre.ethers.getContractAt("IUniswapV2Router", UNIRouter, tokenHolder);
    const UseSwap = await hre.ethers.getContractFactory("UseSwap");
    const useSwap = await UseSwap.connect(tokenHolder).deploy(UNIRouter);

    return { tokenHolder, USDC, DAI, UniRouter, useSwap };
  }

  describe("Handle Swap Check", function () {
    it("Should increment swapCount on handleSwap", async function () {
      const { tokenHolder, USDC, useSwap } = await loadFixture(deployUniswapFixtures);

      const amountOut = hre.ethers.parseUnits("100", 18); 
      const amountInMax = hre.ethers.parseUnits("110", 6);
      const path = [USDCAddress, DAIAddress];
      const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

      await USDC.approve(await useSwap.getAddress(), amountInMax);

      expect(await useSwap.swapCount()).to.equal(0);

      await useSwap.connect(tokenHolder).handleSwap(
        amountOut,
        amountInMax,
        path,
        tokenHolder.address,
        deadline
      );

      expect(await useSwap.swapCount()).to.equal(1);
    });

    it("Should handleSwapToken", async function(){
        const { tokenHolder, USDC, useSwap } = await loadFixture(deployUniswapFixtures);

      const amountIn = hre.ethers.parseUnits("90", 6); 
      const amountOutMin = hre.ethers.parseUnits("80", 18);
      const path = [USDCAddress, DAIAddress];
      const deadline = Math.floor(Date.now() / 1000) + 60 * 10;

      await USDC.approve(await useSwap.getAddress(), amountIn);

      await useSwap.connect(tokenHolder).handleSwapToken(
        amountIn,
        amountOutMin,
        path,
        tokenHolder.address,
        deadline
      )
      expect(await useSwap.swapCountToken()).to.equal(1);
    })
  });
});