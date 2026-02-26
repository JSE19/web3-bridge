import { ethers } from "hardhat";

async function main() {
  // Get the contract address from your deployment
  const contractAddress = "0x440fA7dBC6DD17BA0Dd7b4B7c2680E6a572f6F21";
  
  // Get all available signers
  const signers = await ethers.getSigners();
  console.log(`Available signers: ${signers.map(s => s.address).join(", ")}`);
  
  // Use the first signer (the one with the private key in .env)
  const signer = signers[0];
  const signerAddress = await signer.getAddress();
  
  console.log(`Using signer: ${signerAddress}`);
  
  // Get the contract instance
  const contract = await ethers.getContractAt("GaniToken", contractAddress, signer);
  
  // Get contract owner
  const owner = await contract.owner();
  console.log(`Contract owner: ${owner}`);
  
  // Mint parameters
  const toAddress = "0xa57686f076BEC43a7F0031aE58325C9ce8187a85"; // recipient address
  const tokenId = 2;
  const tokenURI = "ipfs://Qmcz276NrPAFnqjGrKSRBwds2dNa8msdgkPGRczURHjaVo"; // metadata URL
  
  // Call safeMint
  console.log(`Minting token #${tokenId} to ${toAddress}...`);
  const tx = await contract.safeMint(toAddress, tokenId, tokenURI);
  const receipt = await tx.wait();
  
  console.log(`✓ Minted token #${tokenId} to ${toAddress}`);
  console.log(`Transaction hash: ${receipt?.hash}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});