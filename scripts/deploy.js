async function main() {

  const [ deployer ] = await ethers.getSigners();

  console.log("Deploying IPC Contract using the account:", deployer.address);
  let ContractFactory = await ethers.getContractFactory("IPCContract");

  let deploymentData = ContractFactory.interface.encodeDeploy();
  let estimatedGas = await ethers.provider.estimateGas({data: deploymentData});

  console.log("Gas price: " + estimatedGas);

  let contract = await ContractFactory.deploy();
  console.log("Contract address:", contract.address);

  for (index = 0; index < 100; index++)
    await contract.connect(deployer).mint();

  console.log("Deploying Wrapper Contract using the account:", deployer.address);
  ContractFactory = await ethers.getContractFactory("IPCWrapper");

  deploymentData = ContractFactory.interface.encodeDeploy([contract.address]);
  estimatedGas = await ethers.provider.estimateGas({data: deploymentData});

  console.log("Gas price: " + estimatedGas);

  wrapper = await ContractFactory.deploy(contract.address);
  console.log("Contract address:", wrapper.address);

  let result = await wrapper.getIpc(1);
  console.log(result);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
