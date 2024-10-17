import { ethers } from 'hardhat';

const addresses = require('./addresses.json');

// yarn hardhat run --network opmain scripts/01_mainnet/06_erc404/deploy_pool.ts
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
