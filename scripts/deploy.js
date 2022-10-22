// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.
const hre = require("hardhat");
const fs = require("fs");
const { ethers } = require("hardhat");

async function main() {
  const NFTItem = await hre.ethers.getContractFactory("NFTItem")
  let [admin] = await ethers.getSigners()
  const nftInstance = await NFTItem.deploy()
  await nftInstance.deployed()
  console.log("NFTItem deployed to:", nftInstance.address)

  fs.writeFileSync('./config.js', `
    export const nftItemAddress = "${nftInstance.address}"
  `)
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
