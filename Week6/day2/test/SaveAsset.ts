import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre from "hardhat";


describe("SaveAsset", function() {
     async function deploySaveAsset(){
        const [user] = await hre.ethers.getSigners();

        const ERC20 = await hre.ethers.getContractFactory("ERC20");
        const erc20 = await ERC20.deploy("RAJToken", "RAJ", 18, 1000000);
        //getContractFactory() is used to the instance of the contract you want to deploy for testing.
        const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
        const saveAsset = await SaveAsset.deploy(erc20.target);

        const owner = saveAsset.getAddress();
        erc20.mint(user,100);
        erc20.connect(user).approve(owner,100);

        return {saveAsset, owner,user, erc20};
    }

    describe("Deposit And Withdraw Ether", function(){
        it("Should deposit ether", async function(){
            const {saveAsset} = await loadFixture(deploySaveAsset);
            await saveAsset.deposit({value: hre.ethers.parseEther("2")});
            const balance = await saveAsset.getUserSavings();
            expect(balance).to.equal(hre.ethers.parseEther("2"));
        })
        it("should withdraw ether", async function(){
            const {saveAsset} = await loadFixture(deploySaveAsset);
            await saveAsset.deposit({value: hre.ethers.parseEther("2")});
            await saveAsset.withdraw(2000000000000000000n);
            const balance = await saveAsset.getUserSavings();
            expect(balance).to.equal(hre.ethers.parseEther("0"));
        })
    })

    describe("Deposit And Withdraw ERC20 Token", function(){
        it("Should deposit token", async function(){
            const {saveAsset,user, erc20} = await loadFixture(deploySaveAsset);
            await saveAsset.connect(user).depositERC20(50);
            //await erc20.approve(saveAsset.target, 50);
            //await saveAsset.depositERC20(50);
            const balance = await saveAsset.getErc20SavingsBalance();

            expect(balance).to.equal(50);
        })
        it("Should withdraw token", async function(){
            const {saveAsset, user, erc20} = await loadFixture(deploySaveAsset);
            await saveAsset.connect(user).depositERC20(50)
            // await erc20.approve(saveAsset.target, 5000000000000000000000n);
            // await saveAsset.depositERC20(5000000000000000000000n);
            await saveAsset.connect(user).withdrawERC20(30);
            const balance = await saveAsset.getErc20SavingsBalance();
            expect(balance).to.equal(20);
        })
        it("should revert withdraw if insufficient funds", async function(){

            const {saveAsset,user, erc20} = await loadFixture(deploySaveAsset);
            const withdraw = saveAsset.connect(user).withdrawERC20(300);
            await expect(withdraw).to.be.revertedWith("Not enough savings");
        })
    })
})

// describe("Save Asset", function () {

//   async function deploySaveAsset() {
//     const token = "0xfab5Fa47Ed17c48F1866aaEF2087b764df7EBb96"
//     const [owner, addr1] = await hre.ethers.getSigners();
//     const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
//     const saveAsset = await SaveAsset.deploy(token);
//     return { saveAsset, owner, addr1 };
//   }

//   it("Should deposit ETH", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0"); 

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount);
//   });

//   it("Should withdraw ETH", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0");
//     const withdrawAmount = hre.ethers.parseEther("0.5");

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     await saveAsset.connect(addr1).withdrawEther(withdrawAmount);

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount - withdrawAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount - withdrawAmount);
//   });

//   it("Should deposit Token", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0"); 

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount);
//   });

// describe("SaveAsset", function() {

//      async function deploySaveAsset(){
//         const [user1] = await hre.ethers.getSigners();

//         const ERC20 = await hre.ethers.getContractFactory("ERC20");
//         const erc20 = await ERC20.deploy("RAJToken", "RAJ", 18, 1000);
        

//         //const tokenAddress = erc20.getAddress();

//         const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
//         const saveAsset = await SaveAsset.deploy(erc20.target);

//         const owner = saveAsset.getAddress();

//         await ERC20.mint(user1.address, 10)
//         await ERC20.connect(user1).approve(owner,10);
//         return {saveAsset, tokenAddress, owner, erc20};
//     }

//     describe("Deposit And Withdraw Ether", function(){
//         it("should deposit ether", async function(){
//             const {saveAsset} = await loadFixture(deploySaveAsset);
//             await saveAsset.deposit({value: hre.ethers.parseEther("2")});
//             const balance = await saveAsset.getUserSavings();
//             expect(balance).to.equal(hre.ethers.parseEther("2"));
//         })
//         it("should withdraw ether", async function(){
//             const {saveAsset} = await loadFixture(deploySaveAsset);
//             await saveAsset.deposit({value: hre.ethers.parseEther("2")});
//             await saveAsset.withdraw(2000000000000000000n);
//             const balance = await saveAsset.getUserSavings();
//             expect(balance).to.equal(hre.ethers.parseEther("0"));
//         })
//     })

//     describe("Deposit And Withdraw ERC20 Token", function(){
//         it("should deposit token", async function(){
//             const {saveAsset, erc20} = await loadFixture(deploySaveAsset);
//             await erc20.approve(saveAsset.target, 5000000000000000000000n);
//             await saveAsset.depositERC20(5000000000000000000000n);
//             const balance = await saveAsset.getErc20SavingsBalance();
//             expect(balance).to.equal(5000000000000000000000n);
//         })
//         it("should withdraw token", async function(){
//             const {saveAsset, erc20} = await loadFixture(deploySaveAsset);
//             await erc20.approve(saveAsset.target, 5000000000000000000000n);
//             await saveAsset.depositERC20(5000000000000000000000n);
//             await saveAsset.withdrawERC20(3000000000000000000000n);
//             const balance = await saveAsset.getErc20SavingsBalance();
//             expect(balance).to.equal(2000000000000000000000n);
//         })
//         it("should revert withdraw if insufficient funds", async function(){
//             const {saveAsset, erc20} = await loadFixture(deploySaveAsset);
//             const withdraw = saveAsset.withdrawERC20(3000000000000000000000n);
//             await expect(withdraw).to.be.revertedWith("Insufficient funds");
//         })
//     })
// })

// describe("Save Asset", function () {

//   async function deploySaveAsset() {
//     const token = "0xfab5Fa47Ed17c48F1866aaEF2087b764df7EBb96"
//     const [owner, addr1] = await hre.ethers.getSigners();
//     const SaveAsset = await hre.ethers.getContractFactory("SaveAsset");
//     const saveAsset = await SaveAsset.deploy(token);
//     return { saveAsset, owner, addr1 };
//   }

//   it("Should deposit ETH", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0"); 

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount);
//   });

//   it("Should withdraw ETH", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0");
//     const withdrawAmount = hre.ethers.parseEther("0.5");

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     await saveAsset.connect(addr1).withdrawEther(withdrawAmount);

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount - withdrawAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount - withdrawAmount);
//   });

//   it("Should deposit Token", async function () {
//     const { saveAsset, addr1 } = await loadFixture(deploySaveAsset);
//     const depositAmount = hre.ethers.parseEther("1.0"); 

//     await saveAsset.connect(addr1).depositEther({ value: depositAmount });

//     expect(await saveAsset.getContractBalance()).to.equal(depositAmount);
//     expect(await saveAsset.etherBalances(addr1.address)).to.equal(depositAmount);
//   });
// });