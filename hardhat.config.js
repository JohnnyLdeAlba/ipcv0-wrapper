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
	"0xf04bd513e7acc041109248ad8ef2c572e2ff106cd458f1bf07cd006a6afed584",
        "0x2dff071309f76f8fcb5bb69ef1b36c4e5ac244d61c3f7a2eaf3c31fc163b09d6",
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
