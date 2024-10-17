import fs from 'fs';
import path from 'path';

const basePath = process.cwd();
const imagesDir = `${basePath}/scripts/generator/images`;
const metadataDir = `${basePath}/scripts/generator/metadata`;

const baseUri = 'ipfs://QmTpC73gcsWp1RkyrzopqcHroEs4B4B1Rd5WK538riqV67';
const baseName = 'ANOME';
const description = 'ANOME';

const metadataList = [];

function getImages(dir: string): Array<{ filename: string; path: string }> | null {
  return fs
    .readdirSync(dir)
    .filter(item => {
      let extension = path.extname(`${dir}/${item}`);
      if (extension == '.png' || extension == '.jpg') {
        return item;
      }
    })
    .map(i => {
      return {
        filename: i,
        path: `${dir}/${i}`,
      };
    });
}

function saveMetadata(image: { filename: string; path: string }) {
  let shortName = image.filename.replace(/\.[^/.]+$/, '');

  let tempMetadata = {
    name: `${baseName} #${shortName}`,
    image: `${baseUri}/${shortName}.png`,
    description: description,
  };

  fs.writeFileSync(`${metadataDir}/${shortName}.json`, JSON.stringify(tempMetadata, null, 2));
  metadataList.push(tempMetadata);
}

function writeMetaData(_data: any) {
  fs.writeFileSync(`${metadataDir}/_metadata.json`, _data);
}

const startCreating = async () => {
  const images = getImages(imagesDir);

  if (images == null) {
    console.log('Can not find images.');
    return;
  }

  await Promise.all(images).then(images => {
    images.forEach(image => {
      saveMetadata(image);
    });
  });
  writeMetaData(JSON.stringify(images, null, 2));
};

startCreating();
