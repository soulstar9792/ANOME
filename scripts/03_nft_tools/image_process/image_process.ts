import fs from 'fs';
import path from 'path';

const dirBase = process.cwd();
const dirImage = `${dirBase}/images`;

function readImageNames(): Array<{ path: string; file: string }> {
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

function getImageInfo(
  images: Array<{ path: string; file: string }>,
): Array<{
  path: string;
  index: number;
  level: number;
  attrs: { top: number; bottom: number; left: number; right: number };
}> {
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
      path: image.path,
      index: cardIndex,
      level: cardLevel,
      attrs: { top: cardTop, bottom: cardBottom, left: cardLeft, right: cardRight },
    };
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

function startProcess() {
  const images = readImageNames();
  console.log(getImageInfo(images));
}

startProcess();
