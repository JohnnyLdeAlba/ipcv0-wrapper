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
	"0x2f79c3a1db8c8e1b9b246e7976b0a17959be3f0c348ef4afc5625514a3c550e2",
        "0x61eb88490827e4f59cdf86aa9a79befd0af6a4015b4c69ed19446a88eb302ef6",
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
