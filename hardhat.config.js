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
	"0x75b34e93441bf336bf823167b3cb53abf66f6ca4a130c68f658dc6ce032a0be9",
        "0x0b88b0e069716f85ddc35abf0b32c126fbc901c1652b7fa6c9b0c52e6d85ee32",
	"0x7d265e8b9eb8612f36a2c9d4a1062fb9a0e5fba8f16b72e0331345df1ea7164f"
      ] 
    }
  }
};
