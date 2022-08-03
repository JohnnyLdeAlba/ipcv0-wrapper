const contractABI = require('../IPCContract.abi.json');

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();

  const contract = new ethers.Contract("0x35D983591bd363BE64afBcD4b6c8A97F3c164dA1", contractABI, deployer);
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
  // await contract.connect(deployer).wrap(5);

  // await contract.connect(deployer).unwrap(14);

  message = await contract.getTokenOwnership(5);
  console.log("Returned: " + message);

  await contract.connect(deployer).changeIpcName(5, "Arkonviox", {value: ethers.utils.parseEther("2")});

/*
  message = await contract.getIpc(2);
  console.log("Returned: " + message);
*/

  message = await contract.getIpc(4);
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
