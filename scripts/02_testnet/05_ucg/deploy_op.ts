import { ethers } from 'hardhat';
import fs from 'fs';
import { parseEther, parseUnits } from 'ethers';

const addresses = require('./addresses.json');
const addressAdmin = '0xD0997FD10EF70aAa36EC2B9f32892Ff0204C21eF';
const addressCaller = '0x56Cc9750B86d45F304636351f5054eEec41dEA26';

const txParam = {
  gasLimit: 90000000,
};

// yarn hardhat run --network optest scripts/02_testnet/05_ucg/deploy_op.ts
async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddr = await deployer.getAddress();
  console.log('account: ', deployerAddr);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  const baseUri = 'ipfs://QmSWQDy4a2nMQhC4MTUTAqQ7NaFir6ocmdXeKuo4Tb664n';
  const CARD = await ethers.getContractFactory('CardNft');
  const card = await CARD.deploy('Nome Card', 'Nome Card', baseUri);
  await card.deploymentTransaction()?.wait();

  await (await card.mint('0x73127E0D08C6151268dFD7F5d4B3c96064993C75', 30000, txParam)).wait();

  const result = {
    card_new: await card.getAddress(),
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
