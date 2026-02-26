// import hre from "hardhat";
// import { expect } from "chai";
// import { HardhatEthers } from "@nomicfoundation/hardhat-ethers/types";
import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";

describe("SaveAsset", () => {
    let ethers: any;
    let loadFixture: <T>(fn: () => Promise<T>) => Promise<T>;

    before(async () => {
        const { ethers: e, networkHelpers } = await hre.network.connect();
        ethers = e;
        loadFixture = networkHelpers.loadFixture;
    });

    // Setup fixture
    async function saveAssetFixture() {
        // Generate some accounts
        const [alice, bob] = await ethers.getSigners();

        // Deploy the contracts
        const ERC20 = await ethers.getContractFactory("ERC20");
        const erc20 = await ERC20.deploy();
        const tokenAddress = erc20.getAddress();

        const SaveAsset = await ethers.getContractFactory("SaveAsset");
        const saveAsset = await SaveAsset.deploy(tokenAddress);
        const owner = saveAsset.getAddress();

        // Mint tokens to users
        await ERC20.mint(alice.address, 1000);
        await ERC20.connect(alice).approve(owner, 1000);
        
        await ERC20.mint(bob.address, 1000);
        await ERC20.connect(bob).approve(owner, 1000);

        return { tokenAddress, saveAsset, owner, alice, bob };
    }

//     describe("depositERC20", async () => {
//         it("Should allow the user to deposit erc20 token", async () => {
//             const { tokenAddress, saveAsset, alice } = await loadFixture(saveAssetFixture);

//             await saveAsset.connect(alice).depositERC20(tokenAddress, 10);
//             const aliceBalance = await saveAsset.connect(alice).getERC20Balance(tokenAddress);
//             expect(aliceBalance).to.be.equal(10);
//         })

//         it("Should revert if amount is zero", async () => {
//             const { saveAsset, tokenAddress, alice } = await loadFixture(saveAssetFixture);

//             await expect(
//                 saveAsset.connect(alice).depositERC20(tokenAddress, 0)
//             ).to.be.revertedWith("Can't deposit zero value");
//         });
//     });
// });