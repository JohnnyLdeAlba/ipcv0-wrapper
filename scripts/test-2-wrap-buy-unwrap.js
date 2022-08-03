const contractABI = require('../IPCWrapper.abi.json');

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();
  const contract = new ethers.Contract("0xAf1018C7CceDF288E6412E072c193492B3Cd6639", contractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  let tokenId = 3;

  message = await contract.getIpc(tokenId);
  console.log("Before Wrap: " + message);

  message = await contract.getTokenOwnership(tokenId);
  console.log("Ownership: " + message);

  // Must approve contract before running this test.
  // await contract.connect(deployer).wrap(tokenId);

  message = await contract.getIpc(tokenId);
  console.log("After Wrap: " + message);

  message = await contract.getTokenOwnership(tokenId);
  console.log("Ownership: " + message);

  // return;

  // Must initiate buy here with contract maxPrice set to 0.
  // Do second price with maxPrice set to MAX.

  await contract.connect(deployer).unwrap(tokenId);

  message = await contract.getIpc(tokenId);
  console.log("After Unwrap: " + message);

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
