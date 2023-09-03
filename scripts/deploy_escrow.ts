import { ethers } from "hardhat";

async function main() {
  const MysteryBoxGame = await ethers.getContractFactory(
    "contracts/TelegramMysteryBox.sol:TelegramMysteryBox"
  );
  const mysteryBoxGame = await MysteryBoxGame.deploy();
  const address = await mysteryBoxGame.getAddress();
  console.log(`MysteryBoxGameescrow deployed to ${address}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
