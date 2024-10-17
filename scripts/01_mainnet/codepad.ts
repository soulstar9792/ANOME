import { ethers } from 'hardhat';
import { parseEther } from 'ethers';

// yarn hardhat run --network opmain scripts/mainnet/codepad.ts
async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddr = await deployer.getAddress();
  console.log('account: ', deployerAddr);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  // 0xadDb731200483Ca45afbCe31108CA3BbB8cE1ff0
  const OME = await ethers.getContractFactory('SimpleToken');
  const ome = await OME.deploy('OME', parseEther('5000000'));
  await ome.waitForDeployment();

  await (await ome.transfer('0xa4906E8589e1FE5085FCAD32aBd0263210E53693', parseEther('5000000'))).wait();
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
