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
	"0x4690c3cfcf45ec6ae05fba518f0ad82246dca5594c7a690890a685fcde3250ee",
        "0x1111d11fda1576b5e52060dac6f43e18f6229f58eaebf701f3a06a336faa865d",
	"0x439da59279db1c53cac466d3a42a62c75ffe9b2db94db607d4c85077bb380c60"
      ] 
    }
  }
};
