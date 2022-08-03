const contractABI = require('../IPCWrapper.abi.json');

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();
  const contract = new ethers.Contract("0x560023dB553ab99442466B09E3fA6307a1929b9f", contractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  let tokenId = 3;

  message = await contract.getProperties();
  console.log("Before: " + message);
  message = await contract.connect(account1).tokenURI(10);
  console.log("Before: " + message);
  message = await contract.connect(account1).contractURI();
  console.log("Before: " + message);
  message = await contract.connect(account1).getIpc(10);
  console.log("Before: " + message);
  message = await contract.connect(account1).ownerOf(10);
  console.log("Before: " + message);
  message = await contract.connect(account1).getTokenIndex(10);
  console.log("Before: " + message);
  message = await contract.connect(account1).getTokenOwnership(10);
  console.log("Before: " + message);


  message = await contract.getProperties();
  console.log("After: " + message);

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
