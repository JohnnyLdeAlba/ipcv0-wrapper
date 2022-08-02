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
	"0xdf399dd23a4c57891dc9fa97619b0f92ae0a9ac8a7abf406d7a650034f17a193",
        "0x5f8e7dcdf8f94195e6fa72e57dc0115e1d7f820d17db4577cd5a24e31806c122",
	"0x439da59279db1c53cac466d3a42a62c75ffe9b2db94db607d4c85077bb380c60"
      ] 
    }
  }
};
