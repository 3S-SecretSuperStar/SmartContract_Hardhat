/** @type import('hardhat/config').HardhatUserConfig */
require("@nomicfoundation/hardhat-toolbox");
require('dotenv').config();

const { INFURA_API_KEY, PRIVATE_KEY } = process.env;

module.exports = {
  solidity: "0.8.23",
  networks: {
    sepolia: {
      url: `https://sepolia.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_API_KEY}`,
      accounts: [`0x${PRIVATE_KEY}`]
    }
  }
};