const { ethers } = require("hardhat");
require('dotenv').config();
const path = require("path");
const fs = require("fs");

async function main() {
    const _tokenAddress = process.env.TOKEN_CONTRACT_ADDRESS;
    const AirdropContract = await ethers.deployContract("AirDrop", [_tokenAddress]);
    const airDropAddress = await AirdropContract.getAddress();
    const StakingContract = await ethers.deployContract("Staking", [_tokenAddress]);
    const stakingAddress = await StakingContract.getAddress();
    console.log("AirDrp Contract deployed to address:", airDropAddress);
    console.log("Staking Contract deployed to address:", stakingAddress);
    saveFrontendFiles(_tokenAddress, airDropAddress, stakingAddress);
}

function saveFrontendFiles(token, airdrop, staking) {
  const contractsDir = path.join(__dirname, "..");

  if (!fs.existsSync(contractsDir)) {
    fs.mkdirSync(contractsDir);
  }

  fs.writeFileSync(
    path.join(contractsDir, "addresses.json"),
    JSON.stringify({ Token: token, AirDrop: airdrop, Staking: staking }, undefined, 2)
  );
}
 
 main()
   .then(() => process.exit(0))
   .catch(error => {
     console.error(error);
     process.exit(1);
});