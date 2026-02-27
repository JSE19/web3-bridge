import { loadFixture } from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { expect } from "chai";
import hre, { ethers } from "hardhat";

describe("MultiSig", function(){
 async  function deploySigFixture(){
    const[signer1,signer2,signer3,outsider] = await hre.ethers.getSigners();

    const MultiSig = await hre.ethers.getContractFactory("MultiSig");
    const multiSig = await MultiSig.deploy([signer1.address,signer2.address,signer3.address], 2);

    return {multiSig, signer1, signer2,signer3,outsider};

 }

 describe("Submit Transaction", function(){
    it("Should Submit Transaction", async function(){
        const{multiSig,signer1,outsider} = await loadFixture(deploySigFixture);

        const amount = hre.ethers.parseEther("10");
        await multiSig.connect(signer1).submitTransaction(outsider, amount);
        const trans = await multiSig.getAllTransactions();
        expect(trans[0].executed).to.equal(false);

    })
    it("Should not allow Unknow Signers", async function(){
      const {multiSig, signer1, outsider} = await loadFixture(deploySigFixture);
      const amount = hre.ethers.parseEther("2");
      await expect(multiSig.connect(outsider).submitTransaction(signer1, amount)).to.be.revertedWith("Not the Owner") ;

    })
    it("Should not Submit Transaction to Address0", async function (){
      const {multiSig,signer2} = await loadFixture(deploySigFixture);
      const amount = hre.ethers.parseEther("2");
      await expect(multiSig.connect(signer2).submitTransaction(ethers.ZeroAddress,amount)).to.be.rejectedWith("Address Should Not Be Address 0");
    })
    it("Should Not Pass in 0 as Amount", async function(){
      const {multiSig,signer3, outsider} = await loadFixture(deploySigFixture);
      await expect(multiSig.connect(signer3).submitTransaction(outsider, 0)).to.be.revertedWith("Amount should not be 0");
    });
 })

 describe("Confirm Transaction", function(){
   it("Should Ensure the Transaction Exists", async function(){
      const {multiSig, signer1,outsider} =await loadFixture(deploySigFixture);
      const amount = hre.ethers.parseEther("2");
      await multiSig.connect(signer1).submitTransaction(outsider,amount);
      //const trans = await multiSig.getAllTransactions();

     await expect(multiSig.connect(signer1).confirmTransaction(5)).to.be.rejectedWith("Transaction Doesnt Exist"); 

   });

  //  it("Should Ensure Transaction is Not Executed Before", async function(){
  //     const{multiSig,signer1,outsider} = await loadFixture(deploySigFixture);

  //     const amount = hre.ethers.parseEther("2");
  //     await multiSig.connect(signer1).submitTransaction(outsider,amount);

      


  //  })

 })

 
})