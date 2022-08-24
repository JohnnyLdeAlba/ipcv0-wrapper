/** @type import('hardhat/config').HardhatUserConfig */

require("@nomicfoundation/hardhat-toolbox");
require("@nomiclabs/hardhat-ethers");
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: "0.8.9",
  defaultNetwork: "hardhat",
  networks: {

    hardhat: {
      allowUnlimitedContractSize: true
    },

    testnet: {
      allowUnlimitedContractSize: true,

      // url: "http://10.0.2.2:7545",
      url: "http://127.0.0.1:8545",
      accounts: [
	"0xd5dba64371f1c2b0c9eea40789bceace42f6bd4d071f61e6df8d331c36d2d859",
        "0xaea5689cdfd8b216df441600eaaa3d9ea656a33b60a6cea784accf55f33e8cc5",
	"0x7d265e8b9eb8612f36a2c9d4a1062fb9a0e5fba8f16b72e0331345df1ea7164f"
      ] 
    },
/*
    mainnet: {
      allowUnlimitedContractSize: true,

      url: "",
      accounts: [ "" ] 
    }
*/
  }
};
