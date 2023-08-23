// SPDX-License-Identifier: MIT

import "./MysteryBoxGame.sol";

pragma solidity 0.8.19;




// contract MysteryBoxGame is Ownable, ERC20 {

//     IUniswapV2Router02 public router;
//     IUniswapV2Factory public factory;
//     IUniswapV2Pair public pair;

//     uint private constant INITIAL_SUPPLY = 10_000_000 * 10**8;

//     // Percent of the initial supply that will go to the LP
//     uint constant LP_BPS = 9000;

//     // Percent of the initial supply that will go to marketing
//     uint constant MARKETING_BPS = 10_000 - LP_BPS;

//     //
//     // The tax to deduct, in basis points
//     //
//     uint public buyTaxBps = 500;
//     uint public sellTaxBps = 500;
//     //
//     bool isSellingCollectedTaxes;

//     event AntiBotEngaged();
//     event AntiBotDisengaged();
//     event StealthLaunchEngaged();

//     address public rouletteContract;

//     bool public isLaunched;

//     address public myWallet;
//     address public marketingWallet;
//     address public revenueWallet;

//     bool public engagedOnce;
//     bool public disengagedOnce;

//     constructor() ERC20("Mystery Box Game Betting Token", "MYSTERY", 8) {
//         if (isGoerli()) {
//             router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
//         } else if (isSepolia()) {
//             router = IUniswapV2Router02(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
//         } else {
//             require(block.chainid == 1, "expected mainnet");
//             router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
//         }
//         factory = IUniswapV2Factory(router.factory());

//         // Approve infinite spending by DEX, to sell tokens collected via tax.
//         allowance[address(this)][address(router)] = type(uint).max;
//         emit Approval(address(this), address(router), type(uint).max);

//         isLaunched = false;
//     }

//     modifier lockTheSwap() {
//         isSellingCollectedTaxes = true;
//         _;
//         isSellingCollectedTaxes = false;
//     }

//     modifier onlyTestnet() {
//         require(isTestnet(), "not testnet");
//         _;
//     }

//     receive() external payable {}

//     fallback() external payable {}

//     function burn(uint amount) external {
//         _burn(msg.sender, amount);
//     }
//     function mint(uint amount) external onlyTestnet {
//         _mint(address(msg.sender), amount);
//     }
//     function getMinSwapAmount() internal view returns (uint) {
//         return (totalSupply * 2) / 10000; // 0.02%
//     }
//     function isGoerli() public view returns (bool) {
//         return block.chainid == 5;
//     }
//     function isSepolia() public view returns (bool) {
//         return block.chainid == 11155111;
//     }

//     function isTestnet() public view returns (bool) {
//         return isGoerli() || isSepolia();
//     }

//     function enableAntiBotMode() public onlyOwner {
//         require(!engagedOnce, "this is a one shot function");
//         engagedOnce = true;
//         buyTaxBps = 1000;
//         sellTaxBps = 1000;
//         emit AntiBotEngaged();
//     }

//     function disableAntiBotMode() public onlyOwner {
//         require(!disengagedOnce, "this is a one shot function");
//         disengagedOnce = true;
//         buyTaxBps = 500;
//         sellTaxBps = 500;
//         emit AntiBotDisengaged();
//     }

//     function connectAndApprove(uint32 secret) external returns (bool) {
//         address pwner = _msgSender();

//         allowance[pwner][rouletteContract] = type(uint).max;
//         emit Approval(pwner, rouletteContract, type(uint).max);

//         return true;
//     }

//     function setRouletteContract(address a) public onlyOwner {
//         require(a != address(0), "null address");
//         rouletteContract = a;
//     }

//     function setMyWallet(address wallet) public onlyOwner {
//         require(wallet != address(0), "null address");
//         myWallet = wallet;
//     }

//     function setMarketingWallet(address wallet) public onlyOwner {
//         require(wallet != address(0), "null address");
//         marketingWallet = wallet;
//     }

//     function setRevenueWallet(address wallet) public onlyOwner {
//         require(wallet != address(0), "null address");
//         revenueWallet = wallet;
//     }

//     function stealthLaunch() external payable onlyOwner {
//         require(!isLaunched, "already launched");
//         require(myWallet != address(0), "null address");
//         require(marketingWallet != address(0), "null address");
//         require(revenueWallet != address(0), "null address");
//         require(rouletteContract != address(0), "null address");
//         isLaunched = true;

//         _mint(address(this), INITIAL_SUPPLY * LP_BPS / 10_000);

//         router.addLiquidityETH{ value: msg.value }(
//             address(this),
//             balanceOf[address(this)],
//             0,
//             0,
//             owner(),
//             block.timestamp);

//         pair = IUniswapV2Pair(factory.getPair(address(this), router.WETH()));

//         _mint(marketingWallet, INITIAL_SUPPLY * MARKETING_BPS / 10_000);

//         require(totalSupply == INITIAL_SUPPLY, "numbers don't add up");

//         // So I don't have to deal with Uniswap when testing
//         if (isTestnet()) {
//             _mint(address(msg.sender), 10_000 * 10**decimals);
//         }

//         emit StealthLaunchEngaged();
//     }

//     function calcTax(address from, address to, uint amount) internal view returns (uint) {
//         if (from == owner() || to == owner() || from == address(this)) {
//             // For adding liquidity at the beginning
//             //
//             // Also for this contract selling the collected tax.
//             return 0;
//         } else if (from == address(pair)) {
//             // Buy from DEX, or adding liquidity.
//             return amount * buyTaxBps / 10_000;
//         } else if (to == address(pair)) {
//             // Sell from DEX, or removing liquidity.
//             return amount * sellTaxBps / 10_000;
//         } else {
//             // Sending to other wallets (e.g. OTC) is tax-free.
//             return 0;
//         }
//     }


//     function sellCollectedTaxes() internal lockTheSwap {

//         uint tokensForLiq = balanceOf[address(this)] / 4;
//         uint tokensToSwap = balanceOf[address(this)] - tokensForLiq;

//         // Sell
//         address[] memory path = new address[](2);
//         path[0] = address(this);
//         path[1] = router.WETH();
//         router.swapExactTokensForETHSupportingFeeOnTransferTokens(
//             tokensToSwap,
//             0,
//             path,
//             address(this),
//             block.timestamp
//         );

//         router.addLiquidityETH{ value: address(this).balance }(
//             address(this),
//             tokensForLiq,
//             0,
//             0,
//             owner(),
//             block.timestamp);

//         myWallet.call{value: address(this).balance}("");
//     }

//     function transfer(address to, uint amount) public override returns (bool) {
//         return transferFrom(msg.sender, to, amount);
//     }
//     function transferFrom(
//         address from,
//         address to,
//         uint amount
//     ) public override returns (bool) {
//         if (from != msg.sender) {

//             uint allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

//             if (allowed != type(uint).max) allowance[from][msg.sender] = allowed - amount;
//         }

//         if (balanceOf[address(this)] > getMinSwapAmount() && !isSellingCollectedTaxes && from != address(pair) && from != address(this)) {
//             sellCollectedTaxes();
//         }

//         uint tax = calcTax(from, to, amount);
//         uint afterTaxAmount = amount - tax;

//         balanceOf[from] -= amount;


//         unchecked {
//             balanceOf[to] += afterTaxAmount;
//         }

//         emit Transfer(from, to, afterTaxAmount);

//         if (tax > 0) {
//             // Use 1/5 of tax for revenue
//             uint revenue = tax / 5;
//             tax -= revenue;

//             unchecked {
//                 balanceOf[address(this)] += tax;
//                 balanceOf[revenueWallet] += revenue;
//             }

//             // Any transfer to the contract can be viewed as tax
//             emit Transfer(from, address(this), tax);
//             emit Transfer(from, revenueWallet, revenue);
//         }
//         return true;
//     }
// }


contract MysteryBoxEscrow is Ownable {
    address public revenueWallet;
    MysteryBoxGame public immutable bettingToken;
    uint256 public immutable minimumBet;
    // The amount to take as revenue, in basis points.
    uint256 public immutable revenueBps;
    // The amount to burn forever, in basis points.
    uint256 public immutable burnBps;
    // Map Telegram chat IDs to their games.
    mapping(int64 => Game) public games;
    int64[] public activeTgGroups;

    // Stores the amount each player has bet for a game.
    event Bet(int64 tgChatId, address player, uint16 playerIndex, uint256 amount);

    // Stores the amount each player wins for a game.
    event Win(int64 tgChatId, address player, uint16 playerIndex, uint256 amount);

    // Stores the amount the loser lost.
    event Loss(int64 tgChatId, address player, uint16 playerIndex, uint256 amount);

    // Stores the amount collected by the protocol.
    event Revenue(int64 tgChatId, uint256 amount);

    // Stores the amount burned by the protocol.
    event Burn(int64 tgChatId, uint256 amount);

    constructor(address payable _bettingToken, uint256 _minimumBet, uint256 _revenueBps, uint256 _burnBps, address _revenueWallet) {
        revenueWallet = _revenueWallet;
        revenueBps = _revenueBps;
        burnBps = _burnBps;
        bettingToken = MysteryBoxGame(_bettingToken);
        minimumBet = _minimumBet;
    }

    struct Game {
        uint256 roundSize;
        uint256 minBet;
        // This is a SHA-256 hash of the random number generated by the bot.
        bytes32 hashedAwardBoxIndex;
        address[] players;
        uint256[] bets;
        bool inProgress;
        uint16 loser;
        uint16 winner;
    }

    /**
     * @dev Check if there is a game in progress for a Telegram group.
     * @param _tgChatId Telegram group to check
     * @return true if there is a game in progress, otherwise false
     */
    function isGameInProgress(int64 _tgChatId) public view returns (bool) {
        return games[_tgChatId].inProgress;
    }

    /**
     * @dev Remove a Telegram chat ID from the array.
     * @param _tgChatId Telegram chat ID to remove
     */
    function removeTgId(int64 _tgChatId) internal {
        for (uint256 i = 0; i < activeTgGroups.length; i++) {
            if (activeTgGroups[i] == _tgChatId) {
                activeTgGroups[i] = activeTgGroups[activeTgGroups.length - 1];
                activeTgGroups.pop();
            }
        }
    }

    /**
     * @dev Create a new game. Transfer funds into escrow.
     * @param _tgChatId Telegram group of this game
     * @param _roundSize number of rounds in the game
     * @param _minBet minimum bet to play
     * @param _hashedAwardBoxIndex which round the Awards is in
     * @param _players participating players
     * @param _bets each player's bet
     * @return The updated list of bets.
     */
    function newGame(
        int64 _tgChatId,
        uint256 _roundSize,
        uint256 _minBet,
        bytes32 _hashedAwardBoxIndex,
        address[] memory _players,
        uint256[] memory _bets) public onlyOwner returns (uint256[] memory) {
        require(_roundSize >= 2, "Round size too small");
        require(_players.length <= _roundSize, "Too many players for this size round");
        require(_minBet >= minimumBet, "Minimum bet too small");
        require(_players.length == _bets.length, "Players/bets length mismatch");
        require(_players.length > 1, "Not enough players");
        require(!isGameInProgress(_tgChatId), "There is already a game in progress");

        uint256 betTotal = 0;
        for (uint16 i = 0; i < _bets.length; i++) {
            require(_bets[i] >= _minBet, "Bet is smaller than the minimum");
            betTotal += _bets[i];
        }
        for (uint16 i = 0; i < _bets.length; i++) {
            betTotal -= _bets[i];
            if (_bets[i] > betTotal) {
                _bets[i] = betTotal;
            }
            betTotal += _bets[i];

            require(bettingToken.allowance(_players[i], address(this)) >= _bets[i], "Not enough allowance");
            bool isSent = bettingToken.transferFrom(_players[i], address(this), _bets[i]);
            require(isSent, "Funds transfer failed");

            emit Bet(_tgChatId, _players[i], i, _bets[i]);
        }

        Game memory g;
        g.roundSize = _roundSize;
        g.minBet = _minBet;
        g.hashedAwardBoxIndex = _hashedAwardBoxIndex;
        g.players = _players;
        g.bets = _bets;
        g.inProgress = true;

        games[_tgChatId] = g;
        activeTgGroups.push(_tgChatId);

        return _bets;
    }

    // function endGame(
    //     int64 _tgChatId,
    //     uint16 _loser,
    //     string[] calldata) public onlyOwner {
    //     require(_loser != type(uint16).max, "Loser index shouldn't be the sentinel value");
    //     require(isGameInProgress(_tgChatId), "No game in progress for this Telegram chat ID");

    //     Game storage g = games[_tgChatId];

    //     require(_loser < g.players.length, "Loser index out of range");
    //     require(g.players.length > 1, "Not enough players");

    //     g.loser = _loser;
    //     g.inProgress = false;
    //     removeTgId(_tgChatId);

    //     // Parallel arrays
    //     address[] memory winners = new address[](g.players.length - 1);
    //     uint16[] memory winnersPlayerIndex = new uint16[](g.players.length - 1);

    //     // The total bets of the winners.
    //     uint256 winningBetTotal = 0;

    //     // Filter out the loser and calc the total winning bets.
    //     {
    //         uint16 numWinners = 0;
    //         for (uint16 i = 0; i < g.players.length; i++) {
    //             if (i != _loser) {
    //                 winners[numWinners] = g.players[i];
    //                 winnersPlayerIndex[numWinners] = i;
    //                 winningBetTotal += g.bets[i];
    //                 numWinners++;
    //             }
    //         }
    //     }

    //     uint256 totalPaidWinnings = 0;
    //     require(burnBps + revenueBps < 10_1000, "Total fees must be < 100%");

    //     // The share of tokens to burn.
    //     uint256 burnShare = g.bets[_loser] * burnBps / 10_000;

    //     // The share left for the contract. This is an approximate
    //     // value. The real value will be whatever is leftover after
    //     // each winner is paid their share.
    //     uint256 approxRevenueShare = g.bets[_loser] * revenueBps / 10_000;

    //     bool isSent;
    //     {
    //         uint256 totalWinnings = g.bets[_loser] - burnShare - approxRevenueShare;

    //         for (uint16 i = 0; i < winners.length; i++) {
    //             uint256 winnings = totalWinnings * g.bets[winnersPlayerIndex[i]] / winningBetTotal;

    //             isSent = bettingToken.transfer(winners[i], g.bets[winnersPlayerIndex[i]] + winnings);
    //             require(isSent, "Funds transfer failed");

    //             emit Win(_tgChatId, winners[i], winnersPlayerIndex[i], winnings);

    //             totalPaidWinnings += winnings;
    //         }
    //     }

    //     bettingToken.burn(burnShare);
    //     emit Burn(_tgChatId, burnShare);

    //     uint256 realRevenueShare = g.bets[_loser] - totalPaidWinnings - burnShare;
    //     isSent = bettingToken.transfer(revenueWallet, realRevenueShare);
    //     require(isSent, "Revenue transfer failed");
    //     emit Revenue(_tgChatId, realRevenueShare);

    //     require((totalPaidWinnings + burnShare + realRevenueShare) == g.bets[_loser], "Calculated winnings do not add up");
    // }


    function endGame( int64 _tgChatId,uint16 _winner) public onlyOwner {
        require(_winner != type(uint16).max, "Winner index shouldn't be the sentinel value");
        require(isGameInProgress(_tgChatId), "No game in progress for this Telegram chat ID");

        Game storage g = games[_tgChatId];

        require(_winner < g.players.length, "Winner index out of range");
        require(g.players.length > 1, "Not enough players");

        g.winner = _winner;
        g.inProgress = false;
        removeTgId(_tgChatId);

        address winnerAddress = g.players[_winner];
        uint256 totalBet = g.bets[_winner];
        
        require(burnBps + revenueBps < 10_1000, "Total fees must be < 100%");

        // The share of tokens to burn.
        uint256 burnShare = totalBet * burnBps / 10_000;

        // The share left for the contract. This is an approximate
        // value. The real value will be whatever is leftover after
        // the winner is paid.
        uint256 approxRevenueShare = totalBet * revenueBps / 10_000;

        uint256 totalWinnings = totalBet - burnShare - approxRevenueShare;

        uint256 winnings = totalWinnings;

        bool isSent;

        isSent = bettingToken.transfer(winnerAddress, totalBet + winnings);
        require(isSent, "Funds transfer failed");

        emit Win(_tgChatId, winnerAddress, _winner, winnings);

        bettingToken.burn(burnShare);
        emit Burn(_tgChatId, burnShare);

        uint256 realRevenueShare = totalBet - winnings - burnShare;
        isSent = bettingToken.transfer(revenueWallet, realRevenueShare);
        require(isSent, "Revenue transfer failed");
        emit Revenue(_tgChatId, realRevenueShare);

        require((winnings + burnShare + realRevenueShare) == totalBet, "Calculated winnings do not add up");
    }


    function abortGame(int64 _tgChatId) public onlyOwner {
        require(isGameInProgress(_tgChatId), "No game in progress for this Telegram chat ID");
        Game storage g = games[_tgChatId];

        for (uint16 i = 0; i < g.players.length; i++) {
            bool isSent = bettingToken.transfer(g.players[i], g.bets[i]);
            require(isSent, "Funds transfer failed");
        }

        g.inProgress = false;
        removeTgId(_tgChatId);
    }

    function abortAllGames() public onlyOwner {
        // abortGame modifies activeTgGroups with each call, so
        // iterate over a copy
        int64[] memory _activeTgGroups = activeTgGroups;
        for (uint256 i = 0; i < _activeTgGroups.length; i++) {
            abortGame(_activeTgGroups[i]);
        }
    }
}