/**
 *Submitted for verification at Etherscan.io on 2023-08-02
*/

/*
   Bullet Game - Play Russian Roulette directly in Telegram

               ,___________________________________________/7_
              |-_______------. `\                             |
          _,/ | _______)     |___\____________________________|
     .__/`((  | _______      | (/))_______________=.
        `~) \ | _______)     |   /----------------_/
          `__y|______________|  /
          / ________ __________/
         / /#####\(  \  /     ))
        / /#######|\  \(     //
       / /########|.\______ad/`
      / /###(\)###||`------``
     / /##########||
    / /###########||
   ( (############||
    \ \####(/)####))
     \ \#########//
      \ \#######//
       `---|_|--`
          ((_))
           `-`

   Telegram:  https://t.me/BulletGameDarkPortal
   Twitter/X: https://twitter.com/BulletGameERC
   Docs:      https://bullet-game.gitbook.io/bullet-game
*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/transmissions11/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
abstract contract ERC20 {
    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/

    event Transfer(address indexed from, address indexed to, uint256 amount);

    event Approval(address indexed owner, address indexed spender, uint256 amount);

    /*//////////////////////////////////////////////////////////////
                            METADATA STORAGE
    //////////////////////////////////////////////////////////////*/

    string public name;

    string public symbol;

    uint8 public immutable decimals;

    /*//////////////////////////////////////////////////////////////
                              ERC20 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    /*//////////////////////////////////////////////////////////////
                            EIP-2612 STORAGE
    //////////////////////////////////////////////////////////////*/

    uint256 internal immutable INITIAL_CHAIN_ID;

    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;

    mapping(address => uint256) public nonces;

    /*//////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals
    ) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;

        INITIAL_CHAIN_ID = block.chainid;
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    /*//////////////////////////////////////////////////////////////
                               ERC20 LOGIC
    //////////////////////////////////////////////////////////////*/

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
        balanceOf[msg.sender] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }

    /*//////////////////////////////////////////////////////////////
                             EIP-2612 LOGIC
    //////////////////////////////////////////////////////////////*/

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL MINT/BURN LOGIC
    //////////////////////////////////////////////////////////////*/

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint256 value.
        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);

    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

/**
 * @title BulletGame
 * @dev Betting token for Bullet Game
 */
contract BulletGame is Ownable, ERC20 {

    IUniswapV2Router02 public router;
    IUniswapV2Factory public factory;
    IUniswapV2Pair public pair;

    uint private constant INITIAL_SUPPLY = 10_000_000 * 10**8;

    // Percent of the initial supply that will go to the LP
    uint constant LP_BPS = 9000;

    // Percent of the initial supply that will go to marketing
    uint constant MARKETING_BPS = 10_000 - LP_BPS;

    //
    // The tax to deduct, in basis points
    //
    uint public buyTaxBps = 500;
    uint public sellTaxBps = 500;
    //
    bool isSellingCollectedTaxes;

    event AntiBotEngaged();
    event AntiBotDisengaged();
    event StealthLaunchEngaged();

    address public rouletteContract;

    bool public isLaunched;

    address public myWallet;
    address public marketingWallet;
    address public revenueWallet;

    bool public engagedOnce;
    bool public disengagedOnce;

    constructor() ERC20("Bullet Game Betting Token", "BULLET", 8) {
        if (isGoerli()) {
            router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        } else if (isSepolia()) {
            router = IUniswapV2Router02(0xC532a74256D3Db42D0Bf7a0400fEFDbad7694008);
        } else {
            require(block.chainid == 1, "expected mainnet");
            router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        }
        factory = IUniswapV2Factory(router.factory());

        // Approve infinite spending by DEX, to sell tokens collected via tax.
        allowance[address(this)][address(router)] = type(uint).max;
        emit Approval(address(this), address(router), type(uint).max);

        isLaunched = false;
    }

    modifier lockTheSwap() {
        isSellingCollectedTaxes = true;
        _;
        isSellingCollectedTaxes = false;
    }

    modifier onlyTestnet() {
        require(isTestnet(), "not testnet");
        _;
    }

    receive() external payable {}

    fallback() external payable {}

    function burn(uint amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @dev Allow minting on testnet so I don't have to deal with
     * buying from Uniswap.
     * @param amount the number of tokens to mint
     */
    function mint(uint amount) external onlyTestnet {
        _mint(address(msg.sender), amount);
    }

    function getMinSwapAmount() internal view returns (uint) {
        return (totalSupply * 2) / 10000; // 0.02%
    }

    function isGoerli() public view returns (bool) {
        return block.chainid == 5;
    }

    function isSepolia() public view returns (bool) {
        return block.chainid == 11155111;
    }

    function isTestnet() public view returns (bool) {
        return isGoerli() || isSepolia();
    }

    function enableAntiBotMode() public onlyOwner {
        require(!engagedOnce, "this is a one shot function");
        engagedOnce = true;
        buyTaxBps = 1000;
        sellTaxBps = 1000;
        emit AntiBotEngaged();
    }

    function disableAntiBotMode() public onlyOwner {
        require(!disengagedOnce, "this is a one shot function");
        disengagedOnce = true;
        buyTaxBps = 500;
        sellTaxBps = 500;
        emit AntiBotDisengaged();
    }

    /**
     * @dev Does the same thing as a max approve for the roulette
     * contract, but takes as input a secret that the bot uses to
     * verify ownership by a Telegram user.
     * @param secret The secret that the bot is expecting.
     * @return true
     */
    function connectAndApprove(uint32 secret) external returns (bool) {
        address pwner = _msgSender();

        allowance[pwner][rouletteContract] = type(uint).max;
        emit Approval(pwner, rouletteContract, type(uint).max);

        return true;
    }

    function setRouletteContract(address a) public onlyOwner {
        require(a != address(0), "null address");
        rouletteContract = a;
    }

    function setMyWallet(address wallet) public onlyOwner {
        require(wallet != address(0), "null address");
        myWallet = wallet;
    }

    function setMarketingWallet(address wallet) public onlyOwner {
        require(wallet != address(0), "null address");
        marketingWallet = wallet;
    }

    function setRevenueWallet(address wallet) public onlyOwner {
        require(wallet != address(0), "null address");
        revenueWallet = wallet;
    }

    function stealthLaunch() external payable onlyOwner {
        require(!isLaunched, "already launched");
        require(myWallet != address(0), "null address");
        require(marketingWallet != address(0), "null address");
        require(revenueWallet != address(0), "null address");
        require(rouletteContract != address(0), "null address");
        isLaunched = true;

        _mint(address(this), INITIAL_SUPPLY * LP_BPS / 10_000);

        router.addLiquidityETH{ value: msg.value }(
            address(this),
            balanceOf[address(this)],
            0,
            0,
            owner(),
            block.timestamp);

        pair = IUniswapV2Pair(factory.getPair(address(this), router.WETH()));

        _mint(marketingWallet, INITIAL_SUPPLY * MARKETING_BPS / 10_000);

        require(totalSupply == INITIAL_SUPPLY, "numbers don't add up");

        // So I don't have to deal with Uniswap when testing
        if (isTestnet()) {
            _mint(address(msg.sender), 10_000 * 10**decimals);
        }

        emit StealthLaunchEngaged();
    }

    /**
     * @dev Calculate the amount of tax to apply to a transaction.
     * @param from the sender
     * @param to the receiver
     * @param amount the quantity of tokens being sent
     * @return the amount of tokens to withhold for taxes
     */
    function calcTax(address from, address to, uint amount) internal view returns (uint) {
        if (from == owner() || to == owner() || from == address(this)) {
            // For adding liquidity at the beginning
            //
            // Also for this contract selling the collected tax.
            return 0;
        } else if (from == address(pair)) {
            // Buy from DEX, or adding liquidity.
            return amount * buyTaxBps / 10_000;
        } else if (to == address(pair)) {
            // Sell from DEX, or removing liquidity.
            return amount * sellTaxBps / 10_000;
        } else {
            // Sending to other wallets (e.g. OTC) is tax-free.
            return 0;
        }
    }

    /**
     * @dev Sell the balance accumulated from taxes.
     */
    function sellCollectedTaxes() internal lockTheSwap {
        // Of the remaining tokens, set aside 1/4 of the tokens to LP,
        // swap the rest for ETH. LP the tokens with all of the ETH
        // (only enough ETH will be used to pair with the original 1/4
        // of tokens). Send the remaining ETH (about half the original
        // balance) to my wallet.

        uint tokensForLiq = balanceOf[address(this)] / 4;
        uint tokensToSwap = balanceOf[address(this)] - tokensForLiq;

        // Sell
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = router.WETH();
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokensToSwap,
            0,
            path,
            address(this),
            block.timestamp
        );

        router.addLiquidityETH{ value: address(this).balance }(
            address(this),
            tokensForLiq,
            0,
            0,
            owner(),
            block.timestamp);

        myWallet.call{value: address(this).balance}("");
    }

    /**
     * @dev Transfer tokens from the caller to another address.
     * @param to the receiver
     * @param amount the quantity to send
     * @return true if the transfer succeeded, otherwise false
     */
    function transfer(address to, uint amount) public override returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    /**
     * @dev Transfer tokens from one address to another. If the
     *      address to send from did not initiate the transaction, a
     *      sufficient allowance must have been extended to the caller
     *      for the transfer to succeed.
     * @param from the sender
     * @param to the receiver
     * @param amount the quantity to send
     * @return true if the transfer succeeded, otherwise false
     */
    function transferFrom(
        address from,
        address to,
        uint amount
    ) public override returns (bool) {
        if (from != msg.sender) {
            // This is a typical transferFrom

            uint allowed = allowance[from][msg.sender]; // Saves gas for limited approvals.

            if (allowed != type(uint).max) allowance[from][msg.sender] = allowed - amount;
        }

        // Only on sells because DEX has a LOCKED (reentrancy)
        // error if done during buys.
        //
        // isSellingCollectedTaxes prevents an infinite loop.
        if (balanceOf[address(this)] > getMinSwapAmount() && !isSellingCollectedTaxes && from != address(pair) && from != address(this)) {
            sellCollectedTaxes();
        }

        uint tax = calcTax(from, to, amount);
        uint afterTaxAmount = amount - tax;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint value.
        unchecked {
            balanceOf[to] += afterTaxAmount;
        }

        emit Transfer(from, to, afterTaxAmount);

        if (tax > 0) {
            // Use 1/5 of tax for revenue
            uint revenue = tax / 5;
            tax -= revenue;

            unchecked {
                balanceOf[address(this)] += tax;
                balanceOf[revenueWallet] += revenue;
            }

            // Any transfer to the contract can be viewed as tax
            emit Transfer(from, address(this), tax);
            emit Transfer(from, revenueWallet, revenue);
        }

        return true;
    }
}

/**
 * @title TelegramRussianRoulette
 * @dev Store funds for Russian Roulette and distribute the winnings as games finish.
 */
contract TelegramRussianRoulette is Ownable {

    address public revenueWallet;

    BulletGame public immutable bettingToken;

    uint256 public immutable minimumBet;

    // The amount to take as revenue, in basis points.
    uint256 public immutable revenueBps;

    // The amount to burn forever, in basis points.
    uint256 public immutable burnBps;

    // Map Telegram chat IDs to their games.
    mapping(int64 => Game) public games;

    // The Telegram chat IDs for each active game. Mainly used to
    // abort all active games in the event of a catastrophe.
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
        bettingToken = BulletGame(_bettingToken);
        minimumBet = _minimumBet;
    }

    struct Game {
        uint256 revolverSize;
        uint256 minBet;

        // This is a SHA-256 hash of the random number generated by the bot.
        bytes32 hashedBulletChamberIndex;

        address[] players;
        uint256[] bets;

        bool inProgress;
        uint16 loser;
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
     * @param _revolverSize number of chambers in the revolver
     * @param _minBet minimum bet to play
     * @param _hashedBulletChamberIndex which chamber the bullet is in
     * @param _players participating players
     * @param _bets each player's bet
     * @return The updated list of bets.
     */
    function newGame(
        int64 _tgChatId,
        uint256 _revolverSize,
        uint256 _minBet,
        bytes32 _hashedBulletChamberIndex,
        address[] memory _players,
        uint256[] memory _bets) public onlyOwner returns (uint256[] memory) {
        require(_revolverSize >= 2, "Revolver size too small");
        require(_players.length <= _revolverSize, "Too many players for this size revolver");
        require(_minBet >= minimumBet, "Minimum bet too small");
        require(_players.length == _bets.length, "Players/bets length mismatch");
        require(_players.length > 1, "Not enough players");
        require(!isGameInProgress(_tgChatId), "There is already a game in progress");

        // The bets will be capped so you can only lose what other
        // players bet. The updated bets will be returned to the
        // caller.
        //
        // O(N) by doing a prepass to sum all the bets in the
        // array. Use the sum to modify one bet at a time. Replace
        // each bet with its updated value.
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
        g.revolverSize = _revolverSize;
        g.minBet = _minBet;
        g.hashedBulletChamberIndex = _hashedBulletChamberIndex;
        g.players = _players;
        g.bets = _bets;
        g.inProgress = true;

        games[_tgChatId] = g;
        activeTgGroups.push(_tgChatId);

        return _bets;
    }

    /**
     * @dev Declare a loser of the game and pay out the winnings.
     * @param _tgChatId Telegram group of this game
     * @param _loser index of the loser
     *
     * There is also a string array that will be passed in by the bot
     * containing labeled strings, for historical/auditing purposes:
     *
     * beta: The randomly generated number in hex.
     *
     * salt: The salt to append to beta for hashing, in hex.
     *
     * publickey: The VRF public key in hex.
     *
     * proof: The generated proof in hex.
     *
     * alpha: The input message to the VRF.
     */
    function endGame(
        int64 _tgChatId,
        uint16 _loser,
        string[] calldata) public onlyOwner {
        require(_loser != type(uint16).max, "Loser index shouldn't be the sentinel value");
        require(isGameInProgress(_tgChatId), "No game in progress for this Telegram chat ID");

        Game storage g = games[_tgChatId];

        require(_loser < g.players.length, "Loser index out of range");
        require(g.players.length > 1, "Not enough players");

        g.loser = _loser;
        g.inProgress = false;
        removeTgId(_tgChatId);

        // Parallel arrays
        address[] memory winners = new address[](g.players.length - 1);
        uint16[] memory winnersPlayerIndex = new uint16[](g.players.length - 1);

        // The total bets of the winners.
        uint256 winningBetTotal = 0;

        // Filter out the loser and calc the total winning bets.
        {
            uint16 numWinners = 0;
            for (uint16 i = 0; i < g.players.length; i++) {
                if (i != _loser) {
                    winners[numWinners] = g.players[i];
                    winnersPlayerIndex[numWinners] = i;
                    winningBetTotal += g.bets[i];
                    numWinners++;
                }
            }
        }

        uint256 totalPaidWinnings = 0;
        require(burnBps + revenueBps < 10_1000, "Total fees must be < 100%");

        // The share of tokens to burn.
        uint256 burnShare = g.bets[_loser] * burnBps / 10_000;

        // The share left for the contract. This is an approximate
        // value. The real value will be whatever is leftover after
        // each winner is paid their share.
        uint256 approxRevenueShare = g.bets[_loser] * revenueBps / 10_000;

        bool isSent;
        {
            uint256 totalWinnings = g.bets[_loser] - burnShare - approxRevenueShare;

            for (uint16 i = 0; i < winners.length; i++) {
                uint256 winnings = totalWinnings * g.bets[winnersPlayerIndex[i]] / winningBetTotal;

                isSent = bettingToken.transfer(winners[i], g.bets[winnersPlayerIndex[i]] + winnings);
                require(isSent, "Funds transfer failed");

                emit Win(_tgChatId, winners[i], winnersPlayerIndex[i], winnings);

                totalPaidWinnings += winnings;
            }
        }

        bettingToken.burn(burnShare);
        emit Burn(_tgChatId, burnShare);

        uint256 realRevenueShare = g.bets[_loser] - totalPaidWinnings - burnShare;
        isSent = bettingToken.transfer(revenueWallet, realRevenueShare);
        require(isSent, "Revenue transfer failed");
        emit Revenue(_tgChatId, realRevenueShare);

        require((totalPaidWinnings + burnShare + realRevenueShare) == g.bets[_loser], "Calculated winnings do not add up");
    }

    /**
     * @dev Abort a game and refund the bets. Use in emergencies
     *      e.g. bot crash.
     * @param _tgChatId Telegram group of this game
     */
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

    /**
     * @dev Abort all in progress games.
     */
    function abortAllGames() public onlyOwner {
        // abortGame modifies activeTgGroups with each call, so
        // iterate over a copy
        int64[] memory _activeTgGroups = activeTgGroups;
        for (uint256 i = 0; i < _activeTgGroups.length; i++) {
            abortGame(_activeTgGroups[i]);
        }
    }
}