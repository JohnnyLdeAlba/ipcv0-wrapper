const contractABI = require('../IPCWrapper.abi.json');
const oldContractABI = require('../../ipc-contract/IPCContract.abi.json');

const wrapAddress = "0x205D880f9144772A7aC2373eeF9E8Eb9a77f78CB";
const oldAddress = "0xea8F7655cc13ED539CDa9057c2E6F06631f7038f";

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();

  const contract = new ethers.Contract(wrapAddress, contractABI, deployer);
  const oldContract = new ethers.Contract(oldAddress, oldContractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  let tokenId = 7;

  message = await contract.getIpc(tokenId);
  console.log("Before Name Change: " + message);

  message = await contract.getTokenOwnership(tokenId);
  console.log("Ownership: " + message);

  message = await oldContract.getDebugger();
  console.log("Debugger: " + message);

  message = await contract.getDebugger();
  console.log("NuDebugger: " + message);

  // await oldContract.connect(account1).approve(wrapAddress, tokenId);
  // await contract.connect(account1).wrap(tokenId);

  // return;

  await contract.connect(account1).changeIpcName(tokenId, "Eva", {value: ethers.utils.parseEther("1")});

  message = await contract.getIpc(tokenId);
  console.log("After Name Change: " + message);

  message = await contract.getTokenOwnership(tokenId);
  console.log("Ownership: " + message);

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
