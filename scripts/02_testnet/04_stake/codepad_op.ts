import { formatEther, parseEther } from 'ethers';
import { ethers } from 'hardhat';

const addresses = require('./addresses.json');

// yarn hardhat run --network optest scripts/02_testnet/04_stake/codepad_op.ts
async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddr = await deployer.getAddress();
  console.log('account: ', deployerAddr);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  // await grantCoordinatorCaller("0xeDf993B05863FBCe60F96b5C2ECADF99Db4E8633");
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

// await grantCoordinatorCaller("0xeDf993B05863FBCe60F96b5C2ECADF99Db4E8633");
async function grantCoordinatorCaller(account: string) {
  const coordinator = await ethers.getContractAt('AnomeRewarderCoordinator', addresses.staker_coordinator);
  await (await coordinator.grantCaller(account)).wait();
}

// await queryBalance(addresses.usdt, "0x73127E0D08C6151268dFD7F5d4B3c96064993C75");
async function queryBalance(token: string, account: string) {
  const erc20 = await ethers.getContractAt('IERC20', token);
  console.log(formatEther(await erc20.balanceOf(account)));
}

// await transferToken(
//     addresses.usdt,
//     ["0xeDf993B05863FBCe60F96b5C2ECADF99Db4E8633", "0xbb1f0a5aCC59F0307FF8B0e4f2029c522085cC47"],
//     ["100000", "100000"]
// );
async function transferToken(token: string, to: string[], amount: string[]) {
  const erc20 = await ethers.getContractAt('IERC20', token);
  for (let i = 0; i < to.length; i++) {
    await erc20.transfer(to[i], parseEther(amount[i]));
  }
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
