const contractABI = require('../IPCWrapper.abi.json');

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();
  const contract = new ethers.Contract("0x560023dB553ab99442466B09E3fA6307a1929b9f", contractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  message = await contract.getAllTokens(0, 100);
  console.log(message);

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
