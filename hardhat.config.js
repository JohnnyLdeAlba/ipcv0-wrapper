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
	"0x628ddd535959ddb54e4c700ea9b337fc275e621921029c6fb13c681027146f18",
        "0x6fb867259edd6a9bf043f8dc861ee768d40b15fc398a82efb4344c1ee5aca1c1",
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
