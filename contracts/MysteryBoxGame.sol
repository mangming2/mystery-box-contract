// SPDX-License-Identifier: MIT 

pragma solidity 0.8.19;
import '@uniswap/v3-core/contracts/interfaces/callback/IUniswapV3SwapCallback.sol';
import '@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolImmutables.sol';
import '@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolState.sol';
import '@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol';
import '@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolActions.sol';
import '@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol';
import '@uniswap/v3-core/contracts/interfaces/pool/IUniswapV3PoolEvents.sol';



abstract contract ERC20 {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;
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

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;

        unchecked {
            balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        balanceOf[from] -= amount;
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, address(0), amount);
    }
}

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }


    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    /// @notice Emitted when the owner of the factory is changed
    /// @param oldOwner The owner before the owner was changed
    /// @param newOwner The owner after the owner was changed
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice Emitted when a pool is created
    /// @param token0 The first token of the pool by address sort order
    /// @param token1 The second token of the pool by address sort order
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks
    /// @param pool The address of the created pool
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    /// @notice Emitted when a new fee amount is enabled for pool creation via the factory
    /// @param fee The enabled fee, denominated in hundredths of a bip
    /// @param tickSpacing The minimum number of ticks between initialized ticks for pools created with the given fee
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    /// @notice Returns the current owner of the factory
    /// @dev Can be changed by the current owner via setOwner
    /// @return The address of the factory owner
    function owner() external view returns (address);

    /// @notice Returns the tick spacing for a given fee amount, if enabled, or 0 if not enabled
    /// @dev A fee amount can never be removed, so this value should be hard coded or cached in the calling context
    /// @param fee The enabled fee, denominated in hundredths of a bip. Returns 0 in case of unenabled fee
    /// @return The tick spacing
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The pool address
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    /// @notice Creates a pool for the given two tokens and fee
    /// @param tokenA One of the two tokens in the desired pool
    /// @param tokenB The other of the two tokens in the desired pool
    /// @param fee The desired fee for the pool
    /// @dev tokenA and tokenB may be passed in either order: token0/token1 or token1/token0. tickSpacing is retrieved
    /// from the fee. The call will revert if the pool already exists, the fee is invalid, or the token arguments
    /// are invalid.
    /// @return pool The address of the newly created pool
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    /// @notice Updates the owner of the factory
    /// @dev Must be called by the current owner
    /// @param _owner The new owner of the factory
    function setOwner(address _owner) external;

    /// @notice Enables a fee amount with the given tickSpacing
    /// @dev Fee amounts may never be removed once enabled
    /// @param fee The fee amount to enable, denominated in hundredths of a bip (i.e. 1e-6)
    /// @param tickSpacing The spacing between ticks to be enforced for all pools created with the given fee amount
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}

/// @title Router token swapping functionality
/// @notice Functions for swapping tokens via Uniswap V3
interface ISwapRouter is IUniswapV3SwapCallback {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactInputSingleParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);

    struct ExactInputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMinimum;
    }

    /// @notice Swaps `amountIn` of one token for as much as possible of another along the specified path
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactInputParams` in calldata
    /// @return amountOut The amount of the received token
    function exactInput(ExactInputParams calldata params) external payable returns (uint256 amountOut);

    struct ExactOutputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another token
    /// @param params The parameters necessary for the swap, encoded as `ExactOutputSingleParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutputSingle(ExactOutputSingleParams calldata params) external payable returns (uint256 amountIn);

    struct ExactOutputParams {
        bytes path;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMaximum;
    }

    /// @notice Swaps as little as possible of one token for `amountOut` of another along the specified path (reversed)
    /// @param params The parameters necessary for the multi-hop swap, encoded as `ExactOutputParams` in calldata
    /// @return amountIn The amount of the input token
    function exactOutput(ExactOutputParams calldata params) external payable returns (uint256 amountIn);
}


/// @title The interface for a Uniswap V3 Pool
/// @notice A Uniswap pool facilitates swapping and automated market making between any two assets that strictly conform
/// to the ERC20 specification
/// @dev The pool interface is broken up into many smaller pieces
interface IUniswapV3Pool is
    IUniswapV3PoolImmutables,
    IUniswapV3PoolState,
    IUniswapV3PoolDerivedState,
    IUniswapV3PoolActions,
    IUniswapV3PoolOwnerActions,
    IUniswapV3PoolEvents
{

}

interface IUniswapV3PoolDeployer {
    /// @notice Get the parameters to be used in constructing the pool, set transiently during pool creation.
    /// @dev Called by the pool constructor to fetch the parameters of the pool
    /// Returns factory The factory address
    /// Returns token0 The first token of the pool by address sort order
    /// Returns token1 The second token of the pool by address sort order
    /// Returns fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// Returns tickSpacing The minimum number of ticks between initialized ticks
    function parameters()
        external
        view
        returns (
            address factory,
            address token0,
            address token1,
            uint24 fee,
            int24 tickSpacing
        );
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
 * @title MysteryBoxGame
 * @dev Betting token for MysteryBoxGame
 */
contract MysteryBoxGame is Ownable, ERC20 {

    ISwapRouter public router;
    IUniswapV2Router02 public router2;
    IUniswapV3Factory public factory;
    IUniswapV3Pool public pool;
    IUniswapV3PoolDeployer public poolDeployer;

//
//
    // IUniswapV2Router02 public router;
    // IUniswapV2Factory public factory;
    // IUniswapV2Pair public pair;

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

    constructor() ERC20("MysteryBox Game Betting Token", "MYSTERY", 8) {
        if (isGoerli()) {
            router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        } else if (isSepolia()) {
            router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
        } else {
            //require(block.chainid == 1, "expected mainnet");
            //router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
            require(block.chainid == 31337, "expected hardhat");
        }

        //factory = IUniswapV2Factory(router.factory());
        factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);

        // Approve infinite spending by DEX, to sell tokens collected via tax. DEX에서 이 토큰을 거래할 수 있도록 승인
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

        // router.addLiquidityETH{ value: msg.value }(
        //     address(this),
        //     balanceOf[address(this)],
        //     0,
        //     0,
        //     owner(),
        //     block.timestamp);

      

        // Uniswap V3에서 유동성을 추가하는 방식
        address address2 = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
        
        pool = IUniswapV3Pool(factory.getPool(address(this), address2, 3000));

        factory.createPool(address(this), address2, 3000);



       

        _mint(marketingWallet, INITIAL_SUPPLY * MARKETING_BPS / 10_000);

        require(totalSupply == INITIAL_SUPPLY, "numbers don't add up");

        // So I don't have to deal with Uniswap when testing
        if (isTestnet()) {
            _mint(address(msg.sender), 10_000 * 10**decimals);
        }

        emit StealthLaunchEngaged();
    }

    function calcTax(address from, address to, uint amount) internal view returns (uint) {
        if (from == owner() || to == owner() || from == address(this)) {
            // For adding liquidity at the beginning
            //
            // Also for this contract selling the collected tax.
            return 0;
        } else if (from == address(pool)) {
            // Buy from DEX, or adding liquidity.
            return amount * buyTaxBps / 10_000;
        } else if (to == address(pool)) {
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

        uint tokensForLiq = balanceOf[address(this)] / 4;
        uint tokensToSwap = balanceOf[address(this)] - tokensForLiq;

        // Sell
        address[] memory path = new address[](2);
        path[0] = address(this);
        //path[1] = router.WETH();
        path[1] = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
        // router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        //     tokensToSwap,
        //     0,
        //     path,
        //     address(this),
        //     block.timestamp
        // );

        int256 amount0Received;
        int256 amount1Received;
        (amount0Received, amount1Received) = pool.swap(
            address(this),
            false,
            tokensToSwap,
            0,
            bytes("")
        );




        // router.addLiquidityETH{ value: address(this).balance }(
        //     address(this),
        //     tokensForLiq,
        //     0,
        //     0,
        //     owner(),
        //     block.timestamp);

        pool.

        myWallet.call{value: address(this).balance}("");
    }


    function transfer(address to, uint amount) public override returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }
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


        if (balanceOf[address(this)] > getMinSwapAmount() && !isSellingCollectedTaxes && from != address(pool) && from != address(this)) {
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