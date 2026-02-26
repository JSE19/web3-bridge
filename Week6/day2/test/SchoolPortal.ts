import {loadFixture} from '@nomicfoundation/hardhat-toolbox/network-helpers';
import {expect} from 'chai';
import hre, { ethers } from "hardhat";

describe("SchoolPortal", function(){
    async function deploySchoolFixture() {
        const [stud,staff ] = await hre.ethers.getSigners();

        const ERC20 = await hre.ethers.getContractFactory("ERC20");
        const erc20 = await ERC20.deploy("RAJToken", "RAJ", 18, 1000000);

        const SchoolPortal = await hre.ethers.getContractFactory("SchoolPortal");
        const schoolPortal = await SchoolPortal.deploy(erc20.target);
        
        const owner = schoolPortal.getAddress();

        erc20.mint(stud, 300);
        erc20.mint(owner,500);
        
    }
})