import { ethers } from "hardhat";
import { Signer, ContractFactory, Contract } from "ethers";
import { expect } from "chai";

describe("MysteryBoxGame", function () {
  let owner: Signer;
  let user1: Signer;
  let user2: Signer;
  let mysteryBoxGameFactory: ContractFactory;
  let mysteryBoxGame: Contract;

  before(async function () {
    [owner, user1, user2] = await ethers.getSigners();
    mysteryBoxGameFactory = await ethers.getContractFactory("MysteryBoxGame");

    // Deploy the contract
    mysteryBoxGame = await mysteryBoxGameFactory.deploy();
    await mysteryBoxGame.deployed();
  });

  it("should deploy the contract correctly", async function () {
    expect(await mysteryBoxGame.name()).to.equal(
      "MysteryBox Game Betting Token"
    );
    // Add more assertions about the initial state of the contract
  });

  it("should enable and disable anti-bot mode", async function () {
    await mysteryBoxGame.enableAntiBotMode();
    expect(await mysteryBoxGame.buyTaxBps()).to.equal(1000);

    await mysteryBoxGame.disableAntiBotMode();
    expect(await mysteryBoxGame.buyTaxBps()).to.equal(500);
  });

  // Add more test cases to cover different functions and scenarios
});
