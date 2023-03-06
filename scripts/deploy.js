// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const { ethers } = require("hardhat");
const hre = require("hardhat");

async function main() {
  const [deployer] = await ethers.getSigners();
  console.log('Deploying contracts with the account: ' + deployer.address);

  // Deploy First
  const BusinessNFT = await ethers.getContractFactory('BusinessNFT');
  const businessNFT = await BusinessNFT.deploy();

  // Deploy Second
  const ItemNFT = await ethers.getContractFactory('itemNFT');
  const itemNFT = await ItemNFT.deploy(businessNFT.address);

  // Deploy Third

  const Vault = await ethers.getContractFactory('Vault');
  const vault = await Vault.deploy(itemNFT.address)

  console.log( "BusinessNFT: " + businessNFT.address );
  console.log( "itemNFT: " + itemNFT.address ); 
  console.log( "Vault: " + vault.address )
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
