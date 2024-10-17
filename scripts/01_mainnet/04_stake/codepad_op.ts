import { parseEther } from 'ethers';
import { ethers } from 'hardhat';

const addresses = require('./addresses.json');

// yarn hardhat run --network opmain scripts/01_mainnet/04_stake/codepad_op.ts
async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddr = await deployer.getAddress();
  console.log('account: ', deployerAddr);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  await grantCoordinatorCaller('0x037fEd5b6B6ee92C97Eb17b7bAB5EF1dF491173E');
}

async function queryReferralCode(account: string) {
  const referral = await ethers.getContractAt('Referral', addresses.staker_referral);
  return await referral.codeByAccount(account);
}

async function callOnBattle(winner: string, loser: string, amount: string) {
  const rewarder = await ethers.getContractAt('AnomeRewarderCoordinator', addresses.staker_coordinator);
  await (await rewarder.onBattle(winner, loser, parseEther(amount))).wait();
}

async function queryCurrentBoost(account: string) {
  const coordinator = await ethers.getContractAt('AnomeRewarderCoordinator', addresses.staker_coordinator);
  return await coordinator.accountCurrentBoost(account);
}

async function queryONFT(account: string) {
  const onft = await ethers.getContractAt('oNFT', addresses.staker_oNFT);
  return await onft.tokensOfOwner(account);
}

async function queryVNome(account: string) {
  const vNome = await ethers.getContractAt('vNome', addresses.staker_vNome);
  return await vNome.balanceOf(account);
}

async function grantCoordinatorCaller(account: string) {
  const coordinator = await ethers.getContractAt('AnomeRewarderCoordinator', addresses.staker_coordinator);
  await (await coordinator.grantCaller(account)).wait();
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
