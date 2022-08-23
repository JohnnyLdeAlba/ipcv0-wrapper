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
	"0xeec0cde1648d93fd0dfb18b755e8464e90c13b0e80ca65db51d2c8c06f2ebf95",
        "0x20dde26b053b5f68e33cd9d2c14788ed23f6e145952abd8ac994eb804f2cab67",
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
