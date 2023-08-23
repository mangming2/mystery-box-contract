import { ethers } from "hardhat";

async function main() {
  const _bettingToken = "0xcC53d0295Cf29ad77896393E81237fE3109e71FD"; // 배팅에 사용되는 토큰의 주소
  const _minimumBet = 100; // 최소 배팅 금액
  const _revenueBps = 100; // 수익금 비율 (basis points)
  const _burnBps = 50; // 소각 비율 (basis points)
  const _revenueWallet = "0xcC53d0295Cf29ad77896393E81237fE3109e71FD"; // 수익금이 전송될 월렛 주소
  const MysteryBoxEscrow = await ethers.getContractFactory("MysteryBoxEscrow");
  const mysteryBoxEscrow = await MysteryBoxEscrow.deploy(
    _bettingToken,
    _minimumBet,
    _revenueBps,
    _burnBps,
    _revenueWallet
  );
  await mysteryBoxEscrow.waitForDeployment();
  console.log(`MysteryBoxEscrow deployed to ${mysteryBoxEscrow.target}`);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
