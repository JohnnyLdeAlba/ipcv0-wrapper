const contractABI = require('../IPCWrapper.abi.json');

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();
  const contract = new ethers.Contract("0x557F6D80df6F25aC9272EB4b1e136EcAcbD9d0c7", contractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  let tokenId = 14;

  // await contract.connect(deployer).wrap(tokenId);
  // await contract.connect(deployer).unwrap(14);

  message = await contract.getTokensOfOwner(deployer.getAddress(), 10, 20);
  console.log("Returned: " + message);

  message = await contract.getIpc(tokenId);
  console.log("Returned: " + message);

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
