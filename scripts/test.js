const contractABI = require('../IPCContract.abi.json');

async function mint(contract, deployer, quantity) {

  let index;
  for (index = 0; index < quantity; index++) {

    await contract.connect(deployer).createRandomizedIpc(
      "Adam",
      1000,
      {value: ethers.utils.parseEther("1")}
    );
  }
}

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();

  const contract = new ethers.Contract("0xC58Bc35954b5a7C00Bb4016368c634925944a65B", contractABI, deployer);
/*
  contract.on("Logging", (before) => {

    console.log(
      " before: " + before
    );
  });
*/
  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);


  let message = await contract.name();
  console.log("Returned: " + message);
/*
  message = await contract.getIpc(1);
  console.log("Returned: " + message);
  message = await contract.ownerOf(1);
  console.log("Returned: " + message);
*/
  await contract.connect(deployer).wrap(14);
  await contract.connect(deployer).unwrap(14);


/*
  await mint(contract, deployer, 101);

  message = await contract.getIpc(2);
  console.log("Returned: " + message);
*/

  message = await contract.getTokenIndex(13);
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
