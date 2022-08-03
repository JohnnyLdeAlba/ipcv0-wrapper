const contractABI = require('../IPCContract.abi.json');

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();

  const contract = new ethers.Contract("0xC379009D0db55D956Fe897965770216E4eE8C180", contractABI, deployer);
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

  let tokenId = 14;

  // await contract.connect(deployer).wrap(tokenId);

  // await contract.connect(deployer).unwrap(14);

  message = await contract.getAllTokens(1, 100);
  console.log("Returned: " + message);

  // await contract.connect(deployer).changeIpcName(tokenId, "Aarkonviox", {value: ethers.utils.parseEther("6")});

/*
  message = await contract.getIpc(2);
  console.log("Returned: " + message);
*/

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
