import { ethers } from 'hardhat';

const addresses = require('./addresses.json');
const addressAdmin = '0xD0997FD10EF70aAa36EC2B9f32892Ff0204C21eF';
const addressCaller = '0x56Cc9750B86d45F304636351f5054eEec41dEA26';

// yarn hardhat run --network optest scripts/02_testnet/06_erc404/codepad.ts
// yarn hardhat run --network opmain scripts/02_testnet/06_erc404/codepad.ts
async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddr = await deployer.getAddress();
  console.log('account: ', deployerAddr);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  const factory = await ethers.getContractAt("CardPoolFactory", addresses.pool_factory);
  const poolInfos = await factory.getAllPools();
  console.log(poolInfos);

  const pool = await ethers.getContractAt("CardPool", poolInfos[0].pool);
  console.log(await pool.currentPrice());
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
