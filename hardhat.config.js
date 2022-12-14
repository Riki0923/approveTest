require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.10",
  defaultNetwork: "mumbai",
  networks: {
    hardhat: {},
    mumbai: {
      url: "https://rpc-mumbai.maticvigil.com",
      accounts: ["0x1cbd3cf2dcf13b0c0dfdf13d1069475cb10cd4fff495a1c67a104f3e4f8e4ef1"],
    },
  },
  etherscan: {
    apiKey: "7X3I65PIG4M895ZAQ9M7J834U3H8P2DXZA",
  },
};