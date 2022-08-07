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
	"0x1a84455a576a551bbf4f8c0d5a06f7566ac6d36be6792b7207bfab64d0d12762",
        "0xd37ed056848aac39a187088389c177e6f389b57a43d13c0162d8ff78798b2e34",
	"0x439da59279db1c53cac466d3a42a62c75ffe9b2db94db607d4c85077bb380c60"
      ] 
    }
  }
};
