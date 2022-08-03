const contractABI = require('../IPCWrapper.abi.json');

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();
  const contract = new ethers.Contract("0x672ED1dDF47D6C80F2C29B449ed8CE1605aFe716", contractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  let tokenId = 1;

  message = await contract.getIpc(tokenId);
  console.log("Before Wrap: " + message);

  message = await contract.getTokenOwnership(tokenId);
  console.log("Ownership: " + message);

  // Must approve contract before running this test.
  await contract.connect(deployer).wrap(tokenId);

  message = await contract.getIpc(tokenId);
  console.log("After Wrap: " + message);

  message = await contract.getTokenOwnership(tokenId);
  console.log("Ownership: " + message);

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
