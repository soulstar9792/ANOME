import { ethers } from 'hardhat';

const addresses = require('./addresses.json');

async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddr = await deployer.getAddress();
  console.log('account: ', deployerAddr);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  await setPeriodUnit(60);
}

async function setPeriodUnit(unit: number) {
  const staker = await ethers.getContractAt('AnomeStaker', addresses.staker_staker);
  await (await staker.setPeriodUnit(unit)).wait();
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
