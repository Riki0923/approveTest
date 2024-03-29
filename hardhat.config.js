require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.10",
  defaultNetwork: "arbitrum",
  networks: {
    hardhat: {},
    // mumbai: {
    //   url: "https://rpc-mumbai.maticvigil.com",
    //   accounts: ["2ddc16fed89ecb3dbef95146b91ca1d5954dece2c4e6064e373597e26c9b4506"],
    // },
    op_goerli: {
      url: "https://eth-goerli.g.alchemy.com/v2/tIAej_5Kj4-1AJoFWxuIsrwOtHMp1JPK",
      accounts: ["2ddc16fed89ecb3dbef95146b91ca1d5954dece2c4e6064e373597e26c9b4506"],
    },
    arbitrum: {
      url: "https://arb-goerli.g.alchemy.com/v2/CTQtgLswhd7lKqTcYCuHIEgUKtxcTsXQ",
      accounts: ["2ddc16fed89ecb3dbef95146b91ca1d5954dece2c4e6064e373597e26c9b4506"]
    }
  },
  etherscan: {
    apiKey: "7X3I65PIG4M895ZAQ9M7J834U3H8P2DXZA",
  },
};