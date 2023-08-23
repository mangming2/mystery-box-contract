import { ethers } from "hardhat";
import { expect } from "chai";
import { Contract, ContractFactory } from "ethers";

describe("MysteryBoxGame Contract", function () {
  let owner: any; // owner 계정
  let player: any; // 플레이어 계정

  beforeEach(async function () {
    [owner, player] = await ethers.getSigners();

    // MysteryBoxGame 컨트랙트 배포
    const MysteryBoxGame: ContractFactory = await ethers.getContractFactory(
      "MysteryBoxGame"
    );
    const mysteryBoxGame = await MysteryBoxGame.deploy();
    await mysteryBoxGame.deployed();
  });

  // 다른 함수들에 대한 테스트 케이스를 필요에 따라 추가합니다.
});
