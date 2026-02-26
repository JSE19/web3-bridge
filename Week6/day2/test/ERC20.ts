import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("ERC20", function(){
    async function deployERC20(){
        const [owner] = await hre.ethers.getSigners();
        //getContractFactory() is used to the instance of the contract you want to deploy for testing.
        const ERC20 = await hre.ethers.getContractFactory("ERC20");
        const erc20 = await ERC20.deploy("RAJToken", "RAJ", 18, 1000);

        return {erc20, owner};
    }

    describe("Deployment", function(){
        it("Should get token name", async function(){
            const {erc20} = await loadFixture(deployERC20);
            const name = await erc20.name();

            expect(name).to.equal("RAJToken");
        })
        it("Should get token symbol", async function(){
            const {erc20} = await loadFixture(deployERC20);
            const symbol = await erc20.symbol();

            expect(symbol).to.equal("RAJ");
        })
        it("should get token decimals", async function(){
            const {erc20} = await loadFixture(deployERC20);
            const decimals = await erc20.decimals();

            expect(decimals).to.equal(18);
        })
        it("should get token total supply", async function(){
            const {erc20} = await loadFixture(deployERC20);
            const total_supply = await erc20.totalSupply();

            expect(total_supply).to.equal(1000000000000000000000n);
        })
        it("should get token balance", async function(){
            const {erc20, owner} = await loadFixture(deployERC20);
            const balanceOf = await erc20.balanceOf(owner);

            expect(balanceOf).to.equal(1000000000000000000000n);
        })
    })
});