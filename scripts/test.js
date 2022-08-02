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

  const contract = new ethers.Contract("0xDf2195e60007d0d4343D707D3cc274edf9eDD1A8", contractABI, deployer);
/*
  contract.on("Logging", (before, after, result) => {

    console.log(
      " before: " + ethers.utils.formatEther(before) +
      " after: " + ethers.utils.formatEther(after) +
      " result: " + ethers.utils.formatEther(result)
    );
  });
*/
  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  await contract.connect(deployer).releaseNewTranche();

  console.log("Tranche released...");

  await mint(contract, deployer, 101);

  message = await contract.getIpc(2);
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
