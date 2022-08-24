const contractABI = require('../IPCWrapper.abi.json');
const oldContractABI = require('../../ipc-contract/IPCContract.abi.json');

const wrapAddress = "0x08dCc023F6fA512bFa5a35c2Beb1F9f4875E79dB";
const oldAddress = "0x4F9Ac42c1a327BafE44c213c8b3b1e16e499Aaa7";

// approve, wrap, unwrap
// deployer: approve, wrap, setPrice, buy, transfer to account1, deployer: unwrap
// deployer: approve, wrap, transfer to account1, deployer: setPrice, buy, account1: unwrap
// deployer: x5 wrap, xfer to account1, account1: x5 unwrap
// account1 x5 approve, wrap, unwrap
// getOwnersTokens, uwGetOwnersTokens, wGetOwnersTokenIds, uwGetOwnersTokenIds, getAllTokens
// admin functions tested (everything getProperties returns

async function main() {

  const [ deployer, account1 ] = await ethers.getSigners();

  const contract = new ethers.Contract(wrapAddress, contractABI, deployer);
  const oldContract = new ethers.Contract(oldAddress, oldContractABI, deployer);

  let before = await deployer.getBalance();
  console.log("Account balance before: " + before);

  let message = await contract.name();
  console.log("Returned: " + message);

  let tokenId = 1;

  message = await contract.getIpc(tokenId);
  console.log("Before: " + message);

  message = await contract.ownerOf(tokenId);
  console.log("Before ownerOf: " + message);

  message = await contract.uwOwnerOf(tokenId);
  console.log("Before Source ownerOf: " + message);


  // let index = 0;
  // for (index = 0; index < 20; index++) {

    // await oldContract.connect(deployer).approve(wrapAddress, tokenId + index);
    // await contract.connect(deployer).wrap(tokenId + index);
    // await contract.connect(account1).approve(deployer.address, tokenId + index);
    // await contract.connect(deployer)["safeTransferFrom(address,address,uint256)"](account1.address, deployer.address, tokenId + index);
  // }

   // await contract.connect(account1)["safeTransferFrom(address,address,uint256)"](account1.address, deployer.address, tokenId);

  // await oldContract.connect(deployer).approve(wrapAddress, tokenId);
  // await contract.connect(deployer).wrap(tokenId);
  // await contract.connect(deployer).changeIpcName(tokenId, "Grumble");
/*
  message = []
  message[0] = await contract.connect(deployer).totalSupply();
  message[1] = await contract.connect(deployer).uwBalanceOf(deployer.address);
  message[2] = await contract.connect(deployer).ownerOf(tokenId);
  message[3] = await contract.connect(deployer).uwOwnerOf(tokenId);
  message[4] = await contract.connect(deployer).wOwnerOf(tokenId);

  console.log(message);
*/
  // await oldContract.connect(deployer).setIpcPrice(tokenId, 0);
  // await oldContract.connect(deployer).buyIpc(tokenId, 0);

  // await contract.connect(deployer)["safeTransferFrom(address,address,uint256)"](deployer.address, account1.address, tokenId);
  // await contract.connect(account1).unwrap(tokenId);

  // await contract.connect(account1).unwrap(tokenId);


  // message = await contract.connect(deployer).uwGetAllTokens(10, 40);
  // console.log(message);


  // await contract.connect(deployer).setContractAddress("0x1B171C2E72f529377949a5B597E93DC14Da586A7");
  // await contract.connect(deployer).setTokenomics(666, 666, true);
  // await contract.connect(deployer).setMetaDataURIs("https://pornhub.com/", "https://ixxx.com/contracturi");

  // message = await contract.connect(deployer).contractURI();
  // console.log("Returned: " + message);
  // message = await contract.connect(deployer).tokenURI(20);
  // console.log("Returned: " + message);

  // message = await contract.connect(deployer).getProperties();
  // console.log("Returned: " + message);

  // await oldContract.connect(deployer).approve(wrapAddress, tokenId);
	
  // await contract.connect(deployer).wrap(tokenId);
  // await contract.connect(deployer).wrap(tokenId);

  // await oldContract.connect(deployer).buyIpc(tokenId, 0);

  // await oldContract.connect(deployer).approve(wrapAddress, tokenId);
  // await contract.connect(deployer).wrap(tokenId);
  // await contract.connect(account1).unwrap(tokenId);

  // await contract.connect(account1).approve(deployer.address, tokenId);
  // await contract.connect(deployer)["safeTransferFrom(address,address,uint256)"](deployer.address, account1.address, tokenId);

  // await contract.connect(deployer).approve(account1.address, tokenId);
  // await contract.connect(account1)["safeTransferFrom(address,address,uint256)"](deployer.address, account1.address, tokenId);

  // await contract.connect(account1).changeIpcName(tokenId, "Jimmy");

  // message = await contract.uwOwnerOf(1);
  // console.log("Returned: " + message);

  message = await contract.getIpc(tokenId);
  console.log("After: " + message);

  message = await contract.ownerOf(tokenId);
  console.log("After ownerOf: " + message);

  message = await contract.uwOwnerOf(tokenId);
  console.log("After Source ownerOf: " + message);

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
