const contractABI = require('../IPCWrapper.abi.json');
// const oldContractABI = require('../../ipc-contract/IPCContract.abi.json');

const wrapAddress = "0xD0f54E91ee2e57EA72B0836565E8dfFDb0a5F950";
const oldAddress = "0xACE8AA6699F1E71f07622135A93140cA296D610a";

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();

  const contract = new ethers.Contract(wrapAddress, contractABI, deployer);
  // const oldContract = new ethers.Contract(oldAddress, oldContractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  let tokenId = 1;

  message = await contract.getTokenIndex(tokenId);
  console.log("Before tokenIndex: " + message);

  message = await contract.getIpc(tokenId);
  console.log("Before: " + message);

  message = await contract.ownerOf(tokenId);
  console.log("Before ownerOf: " + message);

  message = await contract.uwOwnerOf(tokenId);
  console.log("Before Source ownerOf: " + message);

  // message = await oldContract.getDebugger();
  // console.log("Debugger: " + message);

  // message = await contract.getDebugger();
  // console.log("Wrapper Debugger: " + message);
/*
  let index = 0;
  for (index = 0; index < 10; index++) {

    await oldContract.connect(account1).approve(wrapAddress, tokenId + index);
    await contract.connect(account1).wrap(tokenId + index);
  }
*/

  // await oldContract.connect(account1).approve(wrapAddress, tokenId);
  // await contract.connect(account1).wrap(tokenId);
  message = await contract.connect(deployer).getProperties();
  console.log("Returned: " + message);

  // await oldContract.connect(deployer).buyIpc(tokenId, 0);

  // await oldContract.connect(deployer).approve(wrapAddress, tokenId);
  // await contract.connect(account1).unwrap(tokenId);
  // await contract.connect(deployer).wrap(tokenId);

  // await contract.connect(account1).approve(deployer.address, tokenId);
  // await contract.connect(deployer)["safeTransferFrom(address,address,uint256)"](account1.address, deployer.address, tokenId);

  // await contract.connect(deployer).approve(account1.address, tokenId);
  // await contract.connect(account1)["safeTransferFrom(address,address,uint256)"](deployer.address, account1.address, tokenId);

  // await contract.connect(account1).changeIpcName(tokenId, "Jimmy");

  message = await contract.uwOwnerOf(1);
  console.log("Returned: " + message);

  message = await contract.getTokenIndex(tokenId);
  console.log("After tokenIndex: " + message);

  message = await contract.getIpc(tokenId);
  console.log("After: " + message);

  message = await contract.ownerOf(tokenId);
  console.log("After ownerOf: " + message);

  message = await contract.uwOwnerOf(tokenId);
  console.log("After Source ownerOf: " + message);

  let after = await deployer.getBalance();

  console.log("Account balance after: " + after);
  console.log("Difference after:: " + (before - after));
  console.log("Difference after: " + ethers.utils.formatEther((before - after) + ""));
  console.log("Difference after: " + ethers.utils.formatEther((after - before) + ""));
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(2);
  });
