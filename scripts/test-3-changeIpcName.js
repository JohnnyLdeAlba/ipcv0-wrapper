const contractABI = require('../IPCWrapper.abi.json');
const oldContractABI = require('../../ipc-contract/IPCContract.abi.json');

const wrapAddress = "0x8Db86cB5BeF0c76A8C48C403255CE8EDDb3fD0c2";
const oldAddress = "0xf3a8BB61d607c5Fa0a9FBd995c16D412F639731F";

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();

  const contract = new ethers.Contract(wrapAddress, contractABI, deployer);
  const oldContract = new ethers.Contract(oldAddress, oldContractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  let tokenId = 15;

  message = await contract.getIpc(tokenId);
  console.log("Before Name Change: " + message);

  message = await contract.getTokenOwnership(tokenId);
  console.log("Ownership: " + message);

  message = await oldContract.getDebugger();
  console.log("Debugger: " + message);

  message = await contract.getDebugger();
  console.log("NuDebugger: " + message);

  // await oldContract.connect(account1).approve(wrapAddress, tokenId);
  await contract.connect(account1).unwrap(tokenId);

  // return;

  // await oldContract.connect(deployer).buyIpc(tokenId, 1);

  await oldContract.connect(deployer).approve(wrapAddress, tokenId);
  await contract.connect(deployer).wrap(tokenId);

  message = await contract.getIpc(tokenId);
  console.log("After Name Change: " + message);

  message = await contract.getTokenIndex(tokenId);
  console.log("tokenId: " + message);

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
