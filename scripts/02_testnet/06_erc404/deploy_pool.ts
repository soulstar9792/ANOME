import { ethers } from 'hardhat';
import fs from 'fs';
import path from 'path';
import { parseEther } from 'ethers';
import { AnomeCard, CardPoolFactory } from '../../../typechain-types';

const addresses = require('./addresses.json');
const baseUri = 'ipfs://QmcGeaRk1uWuTCfduPgwoWB79JhycFbqHNcB3s9dhymn9L';

// OpBNB主网 const uniswapV2Router = '0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb';
const uniswapV2Router = '0x62ff25cfd64e55673168c3656f4902bd7aa5f0f4';
// OpBNB主网 const uniswapV2PairHash = '0x57224589c67f3f30a6b0d7a1b54cf3153ab84563bc609ef41dfb34f8b2974d2d';
const uniswapV2PairHash = '0xa5934690703a592a07e841ca29d5e5c79b5e22ed4749057bb216dc31100be1c0';
const usdtAddress = addresses.mock_usdt;

const paramReceivers = ['0xA4A5993c5217919602396D03efe27a77D1d61B74', '0x25A4Ad7755ec00a2c2aC248728093Ad9c81cB298'];
const paramRatios = [300, 300];

// yarn hardhat run --network optest scripts/02_testnet/06_erc404/deploy_pool.ts
async function main() {
  const [deployer] = await ethers.getSigners();
  const deployerAddress = await deployer.getAddress();
  console.log('account: ', deployerAddress);
  console.log('balance: ', (await ethers.provider.getBalance(await deployer.getAddress())).toString());
  console.log('-------------------------------');

  const factory = await deployPoolFactory();
  console.log("factory", await factory.getAddress());

  const cardInfos = getCardInfos("images");
  for (let i = 0; i < cardInfos.length; i++) {
    let card = await deployCardNft(cardInfos[i]);
    console.log("card", await card.getAddress());

    await deployPool(deployerAddress, cardInfos[i], card, factory);
  }

  const report = {
    pool_factory: await factory.getAddress(),
  };
  console.log(report);
  updateAddressesFile(report);
}

function updateAddressesFile<T>(updateData: Partial<T>) {
  let path = __dirname + '/addresses.json';
  let rawData = fs.readFileSync(path, 'utf-8');
  let data: T = JSON.parse(rawData);
  let newData = { ...data, ...updateData };
  let newJsonData = JSON.stringify(newData, null, 2);
  fs.writeFileSync(path, newJsonData, 'utf-8');
}

async function deployPoolFactory() {
  const FACTORY = await ethers.getContractFactory('CardPoolFactory');
  const factory = await FACTORY.deploy(usdtAddress, paramReceivers, paramRatios);
  await factory.deploymentTransaction()?.wait();
  return factory;
}

async function deployCardNft(cardInfo: CardInfo) {
  const CARD = await ethers.getContractFactory('AnomeCard');
  const card = await CARD.deploy(
    'Anome Card',
    'ANOME',
    18,
    cardInfo.supply,
    `${baseUri}/${cardInfo.fileName}`,
    uniswapV2Router,
    usdtAddress,
    uniswapV2PairHash,
    cardInfo.attrs,
  );
  await card.deploymentTransaction()?.wait();

  // const usdt = await ethers.getContractAt('IERC20', usdtAddress);
  // await (await card.approve(uniswapV2Router, parseEther(cardInfo.supply + ""))).wait();
  // await (await card.setApprovalForAll(uniswapV2Router, true)).wait();
  // await (await usdt.approve(uniswapV2Router, parseEther('100'))).wait();

  // const router = await ethers.getContractAt('IUniswapV2Router02', uniswapV2Router);
  // const factory = await ethers.getContractAt("IUniswapV2Factory", await router.factory());

  // await (await factory.createPair(await card.getAddress(), usdtAddress)).wait();
  
  // await (
  //   await router.addLiquidity(
  //     await card.getAddress(),
  //     usdtAddress,
  //     parseEther(cardInfo.supply + ""),
  //     parseEther('0.1'),
  //     0,
  //     0,
  //     "0x73127E0D08C6151268dFD7F5d4B3c96064993C75",
  //     2708587048,
  //   )
  // ).wait();

  return card;
}

async function deployPool(deployer: string, cardInfo: CardInfo, card: AnomeCard, poolFactory: CardPoolFactory) {
  const cardAddr = await card.getAddress();
  await (await poolFactory.createPool(cardAddr, cardInfo.initPrice)).wait();

  const poolAddr = (await poolFactory.getPoolByToken(cardAddr)).pool;
  console.log('poolAddr', poolAddr);

  await (await card.setWhitelist(poolAddr, true)).wait();
  await (await card.setWhitelist(poolFactory, true)).wait();
  await (await card.transfer(poolAddr, await card.balanceOf(deployer))).wait();
}

function getCardInfos(foldName: string) {
  const dirImage = `${__dirname}/${foldName}`;
  const images = readImageNames(dirImage);
  const imageInfos = getImageInfo(images);
  return imageInfoToCardInfo(imageInfos);
}

function imageInfoToCardInfo(imageInfos: Array<ImageInfo>): Array<CardInfo> {
  return imageInfos.map(image => {
    let supply = 0;
    let price: bigint = BigInt('0');
    if (image.attrs.level == 1) {
      supply = 30000;
      price = parseEther('3');
    }
    if (image.attrs.level == 2) {
      supply = 20000;
      price = parseEther('5');
    }
    if (image.attrs.level == 3) {
      supply = 10000;
      price = parseEther('10');
    }
    if (image.attrs.level == 4) {
      supply = 8000;
      price = parseEther('13');
    }
    if (image.attrs.level == 5) {
      supply = 6000;
      price = parseEther('17');
    }
    if (image.attrs.level == 6) {
      supply = 3000;
      price = parseEther('33');
    }
    if (image.attrs.level == 7) {
      supply = 2000;
      price = parseEther('50');
    }
    if (image.attrs.level == 8) {
      supply = 1200;
      price = parseEther('83');
    }
    if (image.attrs.level == 9) {
      supply = 1000;
      price = parseEther('100');
    }
    if (image.attrs.level == 10) {
      supply = 500;
      price = parseEther('200');
    }

    return {
      filePath: image.filePath,
      fileName: image.fileName,
      attrs: image.attrs,
      supply: supply,
      initPrice: price,
    };
  });
}

function getImageInfo(images: Array<{ path: string; file: string }>): Array<ImageInfo> {
  return images.map(image => {
    const fileParsed = path.parse(image.file);

    const cardInfo = fileParsed.name.split('_', 3)[0];
    const cardIndex = Number(cardInfo.split(/[a-z]{1,}/)[0]);
    const cardLevel = romanToInt(cardInfo.match(/[a-z]{1,}/)?.[0] as string);

    const cardAttrs = fileParsed.name.split('_', 3)[1];
    const cardTop = parseInt(cardAttrs.charAt(0), 16);
    const cardBottom = parseInt(cardAttrs.charAt(1), 16);
    const cardLeft = parseInt(cardAttrs.charAt(2), 16);
    const cardRight = parseInt(cardAttrs.charAt(3), 16);

    return {
      filePath: image.path,
      fileName: image.file,
      attrs: { top: cardTop, bottom: cardBottom, left: cardLeft, right: cardRight, index: cardIndex, level: cardLevel },
    };
  });
}

function readImageNames(dirImage: string): Array<{ path: string; file: string }> {
  return fs
    .readdirSync(dirImage)
    .filter(item => {
      let extension = path.extname(`${dirImage}/${item}`);
      if (extension == '.png' || extension == '.jpg') {
        return item;
      }
    })
    .map(item => {
      return { path: `${dirImage}/${item}`, file: item };
    });
}

function romanToInt(s: string) {
  const roman = { I: 1, V: 5, X: 10, L: 50, C: 100, D: 500, M: 1000 };
  let ans = 0;
  for (let i = s.length - 1; ~i; i--) {
    let romanChar = s.charAt(i).toUpperCase() as keyof typeof roman;
    let num = roman[romanChar];
    if (4 * num < ans) ans -= num;
    else ans += num;
  }
  return ans;
}

interface ImageInfo {
  filePath: string;
  fileName: string;
  attrs: CardAttr;
}

interface CardInfo {
  filePath: string;
  fileName: string;
  attrs: CardAttr;
  supply: number;
  initPrice: bigint;
}

interface CardAttr {
  top: number;
  bottom: number;
  left: number;
  right: number;
  index: number;
  level: number;
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
