import { ethers } from "hardhat";

async function main() {
  const MysteryBoxGame = await ethers.getContractFactory(
    "contracts/MysteryBoxGame.sol:MysteryBoxGame"
  );
  const mysteryBoxGame = await MysteryBoxGame.deploy();
  console.log(`MysteryBoxGame deployed to ${mysteryBoxGame.getAddress()}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
