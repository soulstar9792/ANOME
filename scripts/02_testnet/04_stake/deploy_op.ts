import { ethers } from 'hardhat';
import fs from 'fs';
import { ONFT__factory, VNome, VNome__factory } from '../../../typechain-types';
import { parseEther } from 'ethers';

const addresses = require('./addresses.json');
const addressAdmin = '0xD0997FD10EF70aAa36EC2B9f32892Ff0204C21eF';
const addressCaller = '0x56Cc9750B86d45F304636351f5054eEec41dEA26';

// yarn hardhat run --network optest scripts/testnet/staker_deploy_op.ts
async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddr = await deployer.getAddress();
  console.log('account: ', deployerAddr);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  const REFERRAL = await ethers.getContractFactory('Referral');
  const referral = await REFERRAL.deploy(addressAdmin, addresses.usdt, parseEther('1'));
  await referral.deploymentTransaction()?.wait();
  const referralAddress = await referral.getAddress();
  await referral.grantCaller(addressCaller);
  console.log(`API_WEB3_OP_REFERRAL=${referralAddress}`);

  const VNOME: VNome__factory = (await ethers.getContractFactory('vNome')) as VNome__factory;
  const vNome = await VNOME.deploy();
  await vNome.deploymentTransaction()?.wait();
  const vNomeAddress = await vNome.getAddress();
  await vNome.grantCaller(addressCaller);
  console.log(`API_WEB3_OP_vNOME=${vNomeAddress}`);

  const ONFT = (await ethers.getContractFactory('oNFT')) as ONFT__factory;
  const oNFT = await ONFT.deploy();
  await oNFT.deploymentTransaction()?.wait();
  const oNFTAddress = await oNFT.getAddress();
  await oNFT.grantCaller(addressCaller);
  console.log(`API_WEB3_OP_oNFT=${oNFTAddress}`);

  const REWARDER = await ethers.getContractFactory('AnomeRewarder');
  const rewarder = await REWARDER.deploy(addressAdmin, addresses.usdt, vNomeAddress);
  await rewarder.deploymentTransaction()?.wait();
  const rewarderAddress = await rewarder.getAddress();
  await rewarder.grantCaller(addressCaller);
  console.log(`API_WEB3_OP_REWARDER=${rewarderAddress}`);

  const COORDINATOR = await ethers.getContractFactory('AnomeRewarderCoordinator');
  const coordinator = await COORDINATOR.deploy(
    addressAdmin,
    vNomeAddress,
    oNFTAddress,
    referralAddress,
    rewarderAddress,
  );
  await coordinator.deploymentTransaction()?.wait();
  const coordinatorAddress = await coordinator.getAddress();
  await coordinator.grantCaller(addressCaller);
  await vNome.grantCaller(coordinatorAddress);
  await oNFT.grantCaller(coordinatorAddress);
  await referral.grantCaller(coordinatorAddress);
  console.log(`API_WEB3_OP_COORDINATOR=${coordinatorAddress}`);

  const result = {
    staker_referral: referralAddress,
    staker_vNome: vNomeAddress,
    staker_rewarder: rewarderAddress,
    staker_coordinator: coordinatorAddress,
    staker_oNFT: oNFTAddress,
  };
  updateAddressesFile(result);
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
