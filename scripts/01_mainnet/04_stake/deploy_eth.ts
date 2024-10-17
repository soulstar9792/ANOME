import { ethers } from 'hardhat';
import fs from 'fs';

const addresses = require('./addresses.json');
const addressCaller = '0x56Cc9750B86d45F304636351f5054eEec41dEA26';

// yarn hardhat run --network ethmain scripts/mainnet/staker_deploy_eth.ts
async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddr = await deployer.getAddress();
  console.log('account: ', deployerAddr);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  const STAKER = await ethers.getContractFactory('AnomeStaker');
  const staker = await STAKER.deploy();
  await staker.deploymentTransaction()?.wait();
  await (await staker.setVaultToken(addresses.nft)).wait();
  console.log(await staker.getAddress());

  updateAddressesFile({ staker_staker: await staker.getAddress() });
}

function updateAddressesFile<T>(updateData: Partial<T>) {
  let path = __dirname + '/addresses.json';
  let rawData = fs.readFileSync(path, 'utf-8');
  let data: T = JSON.parse(rawData);
  let newData = { ...data, ...updateData };
  let newJsonData = JSON.stringify(newData, null, 2);
  fs.writeFileSync(path, newJsonData, 'utf-8');
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
