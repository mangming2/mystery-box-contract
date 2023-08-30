// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;
pragma abicoder v2;

//swap import 
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@uniswap/swap-router-contracts/contracts/interfaces/ISwapRouter02.sol";


//new liquidity provider import 
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";

import "@uniswap/v3-periphery/contracts/interfaces/external/IWETH9.sol";



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






library Address {
    // Tokens
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant SNX = 0xC011a73ee8576Fb46F5E1c5751cA3B9Fe0af2a6F;

    // Addresses
    address public constant UNIV3_FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address public constant UNIV3_ROUTER = 0xE592427A0AEce92De3Edee1F18E0157C05861564;

    address public constant UNIV3_POS_MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address public constant UNIV3_QUOTER = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;

    // Tokens
    address public constant WMATIC_TEST = 0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889;


    //Testnet Mumbai V3
    address public constant UNIV3_FACTORY_TEST = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address public constant UNIV3_ROUTER_TEST = 0xE592427A0AEce92De3Edee1F18E0157C05861564;
    address public constant UNIV3_ROUTER2_TEST = 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45;
    address public constant UNIV3_POS_MANAGER_TEST = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
    address public constant UNIV3_QUOTER_TEST = 0xb27308f9F90D607463bb33eA1BeBb41C27CE5AB6;
}

/**
 * @title MysteryBoxGame
 * @dev Betting token for MysteryBoxGame
 */
contract MysteryBoxGame is Ownable, ERC20  {

     ISwapRouter02 public router;

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

    uint256 constant PRECISION = 2**96;
    

    //?sqrtPriceX = sqrt(amountY/amountX) * 2^96
    uint160 sqrtPriceLimitX96;


    bool isSellingCollectedTaxes;

    event AntiBotEngaged();
    event AntiBotDisengaged();
    event StealthLaunchEngaged();

    

    address public mysteryGameContract;

    bool public isLaunched;

    address public myWallet=0x4ADFB048858346ea1B49361EEdB036AD31ee0E54;
    address public marketingWallet=0x4ADFB048858346ea1B49361EEdB036AD31ee0E54;
    address public revenueWallet=0x4ADFB048858346ea1B49361EEdB036AD31ee0E54;
    address public poolAddress;



    uint24 public constant poolFee = 3000;

    address public token0;
    address public token1;

    IUniswapV3Pool public pool;
    INonfungiblePositionManager public nfpm;
    IUniswapV3Factory public v3Factory;
    uint24 public fee =3000;
    int24 public tickSpacing;


    



    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    mapping(uint256 => Deposit) public deposits;
    
   

    bool public engagedOnce;
    bool public disengagedOnce;



    
    constructor() ERC20("MysteryBox Game Betting Token", "MYSTERY", 8) {
        if (isGoerli()) {
            router = ISwapRouter02(Address.UNIV3_ROUTER);
            
        } else if (isSepolia()) {
            
        } else if (isMumbai()){
            router = ISwapRouter02(Address.UNIV3_ROUTER2_TEST);
            nfpm = INonfungiblePositionManager(Address.UNIV3_POS_MANAGER_TEST);
            v3Factory = IUniswapV3Factory(Address.UNIV3_FACTORY_TEST);
        } else {
            //require(block.chainid == 1, "expected mainnet");
            //router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
            require(block.chainid == 31337, "expected hardhat");
        }
        
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
    function isMumbai() public view returns (bool) {
        return block.chainid == 80001;
    }

    function isGoerli() public view returns (bool) {
        return block.chainid == 5;
    }

    function isSepolia() public view returns (bool) {
        return block.chainid == 11155111;
    }

    function isTestnet() public view returns (bool) {
        return isGoerli() || isSepolia() || isMumbai();
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


// COMM:reserve1 * PRECISION * PRECISION overflow 일어날 수도 있어서 Uniswap FullMath.mulDiv 사용하는 거 추천
// Computes the sqrt of the u64x96 fixed point price given the AMM reserves
function encodePriceSqrt(uint256 reserve1, uint256 reserve0) public pure returns (uint160) {
    return uint160(sqrt((reserve1 * PRECISION * PRECISION) / reserve0));
}

//u64x96 고정 소수점 가격의 제곱근을 계산하고 AMM 예약을 고려합니다.
// Fast sqrt, taken from Solmate.
function sqrt(uint256 x) public pure returns (uint256 z) {
    assembly {
        // Start off with z at 1.
        z := 1

        // Used below to help find a nearby power of 2.
        let y := x

        // Find the lowest power of 2 that is at least sqrt(x).
        if iszero(lt(y, 0x100000000000000000000000000000000)) {
            y := shr(128, y) // Like dividing by 2 ** 128.
            z := shl(64, z) // Like multiplying by 2 ** 64.
        }
        if iszero(lt(y, 0x10000000000000000)) {
            y := shr(64, y) // Like dividing by 2 ** 64.
            z := shl(32, z) // Like multiplying by 2 ** 32.
        }
        if iszero(lt(y, 0x100000000)) {
            y := shr(32, y) // Like dividing by 2 ** 32.
            z := shl(16, z) // Like multiplying by 2 ** 16.
        }
        if iszero(lt(y, 0x10000)) {
            y := shr(16, y) // Like dividing by 2 ** 16.
            z := shl(8, z) // Like multiplying by 2 ** 8.
        }
        if iszero(lt(y, 0x100)) {
            y := shr(8, y) // Like dividing by 2 ** 8.
            z := shl(4, z) // Like multiplying by 2 ** 4.
        }
        if iszero(lt(y, 0x10)) {
            y := shr(4, y) // Like dividing by 2 ** 4.
            z := shl(2, z) // Like multiplying by 2 ** 2.
        }
        if iszero(lt(y, 0x8)) {
            // Equivalent to 2 ** z.
            z := shl(1, z)
        }

        // Shifting right by 1 is like dividing by 2.
        z := shr(1, add(z, div(x, z)))
        z := shr(1, add(z, div(x, z)))
        z := shr(1, add(z, div(x, z)))
        z := shr(1, add(z, div(x, z)))
        z := shr(1, add(z, div(x, z)))
        z := shr(1, add(z, div(x, z)))
        z := shr(1, add(z, div(x, z)))

        // Compute a rounded down version of z.
        let zRoundDown := div(x, z)

        // If zRoundDown is smaller, use it.
        if lt(zRoundDown, z) {
            z := zRoundDown
        }
    }
}

    /**
     * @dev Does the same thing as a max approve for the mysteryGameContract
     * contract, but takes as input a secret that the bot uses to
     * verify ownership by a Telegram user.
     * @param secret The secret that the bot is expecting.
     * @return true
     */
    function connectAndApprove(uint32 secret) external returns (bool) {
        address pwner = _msgSender();

        allowance[pwner][mysteryGameContract] = type(uint).max;
        emit Approval(pwner, mysteryGameContract, type(uint).max);

        return true;
    }

    function setMysteryGameContract(address a) public onlyOwner {
        require(a != address(0), "null address");
        mysteryGameContract = a;
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

        // require(!isLaunched, "already launched");
        // require(myWallet != address(0), "null address");
        // require(marketingWallet != address(0), "null address");
        // require(revenueWallet != address(0), "null address");
        // require(mysteryGameContract != address(0), "null address");
        // isLaunched = true;


        //토큰 발행 일단 테스트 토큰들로 확인!
        _mint(address(this), INITIAL_SUPPLY * LP_BPS / 10_000);

        token1 = Address.WMATIC_TEST;


        

        // token0.approve(address(nfpm), uint256(-1));
        // token1.approve(address(nfpm), uint256(-1));

        
        pool = IUniswapV3Pool(v3Factory.createPool(address(this), token1 , poolFee));
        // Lets set the price to be 1000 token0 = 1 token1
        uint160 sqrtPriceX96 = encodePriceSqrt(1, 1000);
        pool.initialize(sqrtPriceX96);

        tickSpacing = pool.tickSpacing();

        // Get tick spacing
        (, int24 curTick, , , , , ) = pool.slot0();
        curTick = curTick - (curTick % tickSpacing);

        int24 lowerTick = curTick - (tickSpacing * 2);
        int24 upperTick = curTick + (tickSpacing * 2);

        // COMM: amount0Desired는 토큰의 양을 말하는거지 이더의양을 말하는것이 아님! ETH -> WETH로 wrap을 해서 아래처럼 바꾸길 바람.
        //weth: WETH 주소 전역변수로, 형은 MATIC_TEST로 설정
        //IWETH9(weth).deposit({value: msg.value});
        IWETH9(token1).deposit{value: msg.value}();
        nfpm.mint(
            INonfungiblePositionManager.MintParams({
                token0: pool.token0(),
                token1: pool.token1(),
                fee: poolFee, //위에서 선언한 3000, poolFee로 바꿔도 되지 않아?
                tickLower: lowerTick,
                tickUpper: upperTick,
                amount0Desired: 1000,
                amount1Desired: IWETH9(token1).balanceOf(address(this)),
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            })
        );

        // nfpm.mint(
        //     INonfungiblePositionManager.MintParams({
        //         token0: pool.token0(),
        //         token1: pool.token1(),
        //         fee: fee,  //위에서 선언한 3000
        //         tickLower: lowerTick,
        //         tickUpper: upperTick,
        //         amount0Desired: 1000e18,
        //         amount1Desired: msg.value,
        //         amount0Min: 0e18,
        //         amount1Min: 0e18,
        //         recipient: address(this),
        //         deadline: block.timestamp
        //     })
        // );


       // _mint(marketingWallet, INITIAL_SUPPLY * MARKETING_BPS / 10_000);

        //토큰의 총 공급량과 초기 공급량이 일치하는지를 확인
        //require(totalSupply == INITIAL_SUPPLY, "numbers don't add up");

        // So I don't have to deal with Uniswap when testing
        if (isTestnet()) {
            _mint(address(msg.sender), 10_000 * 10**decimals);
        }

        emit StealthLaunchEngaged();
    }



    //세금계산하는 로직 owner이면 0 , owner가 아니면 1/10000 세금 , owner가 아니고 pool이면 1/10000 세금
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
     //lockTheSwap modifier로 보호되어 중복 호출을 방지
    function sellCollectedTaxes() internal lockTheSwap {
        ISwapRouter02 v3router = ISwapRouter02(Address.UNIV3_ROUTER2_TEST);

        //address(this) 계정에 남은 토큰 중 1/4만큼을 유동성에 할당하고, 나머지는 ETH로 스왑합니다.
        //tokensForLiq 변수에는 유동성에 할당될 토큰 양이 저장됩니다.
        //tokensToSwap 변수에는 스왑될 나머지 토큰 양이 저장됩니다.
        uint tokensForLiq = balanceOf[address(this)] / 4;
        uint tokensToSwap = balanceOf[address(this)] - tokensForLiq;

        // Sell
        address[] memory path = new address[](2);

        //path[0] = address(this);
        //path[1] = router.WETH();

        path[0] =address(this);
        path[1] = Address.WMATIC_TEST;

        address[] memory dynamicPath = new address[](2);
        dynamicPath[0] = path[0];
        dynamicPath[1] = path[1];



        v3router.swapExactTokensForTokens(tokensToSwap, 0,dynamicPath, myWallet);
        //    {
        //         path: abi.encodePacked(path[0], fee, path[1]),
        //         recipient: address(this),
        //         amountIn : tokensToSwap,
        //         amountOutMinimum: 0
        //     }
    

    
        //유동성 추가
        pool = IUniswapV3Pool(
            v3Factory.getPool(Address.WMATIC_TEST, address(this), fee)
        );
        tickSpacing = pool.tickSpacing();

        // Get pool current tick, make sure the ticks are correct
        (, int24 curTick, , , , , ) = pool.slot0();
        curTick = curTick - (curTick % tickSpacing);

        int24 lowerTick = curTick - (tickSpacing * 2);
        int24 upperTick = curTick + (tickSpacing * 2);


        // nfpm.mint(
        //         INonfungiblePositionManager.MintParams({
        //             token0: path[0],
        //             token1: path[1],
        //             fee: fee,
        //             tickLower: lowerTick,
        //             tickUpper: upperTick,
        //             amount0Desired: tokensForLiq,
        //             amount1Desired: 0e18,
        //             amount0Min: 0e18,
        //             amount1Min: 0e18,
        //             recipient: address(this),
        //             deadline: block.timestamp
        //         })
        //     );

            nfpm.mint(
            INonfungiblePositionManager.MintParams({
                token0: pool.token0(),
                token1: pool.token1(),
                fee: poolFee, //위에서 선언한 3000, poolFee로 바꿔도 되지 않아?
                tickLower: lowerTick,
                tickUpper: upperTick,
                amount0Desired: tokensForLiq,
                amount1Desired: 0,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            })
        );
       
            
        
        //토큰 스왑
        // router.swapExactTokensForETHSupportingFeeOnTransferTokens(
        //     tokensToSwap,
        //     0,
        //     path,
        //     address(this),
        //     block.timestamp
        // );


        //유동성 추가
                // router.addLiquidityETH{ value: address(this).balance }(
        //     address(this),
        //     tokensForLiq,
        //     0,
        //     0,
        //     owner(),
        //     block.timestamp);


        //내 지갑에 잔액 eth잔액 전송
        (bool success , ) = myWallet.call{value: address(this).balance}("");
        require(success, "Transfer failed.");
    }

   


    function transfer(address to, uint amount) public override returns (bool) {
        return transferFrom(msg.sender, to, amount);
    }

    function uncheckedAdd(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
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
        //calcTax 함수에서 세금을 계산

        uint tax = calcTax(from, to, amount);
        uint afterTaxAmount = amount - tax;

        balanceOf[from] -= amount;

        // Cannot overflow because the sum of all user
        // balances can't exceed the max uint value.
        //to 주소의 잔액에 세금을 고려한 실제 전송량을 더합니다. 
        //이때 오버플로우를 방지하기 위해 unchecked 블록 내에서 연산을 수행합니다.
        // unchecked {
        //     balanceOf[to] += afterTaxAmount;
        // }
        balanceOf[to] = uncheckedAdd(balanceOf[to], afterTaxAmount);

        emit Transfer(from, to, afterTaxAmount);

        //세금의 1/5를 수익으로 사용합니다.
        //세금과 수익을 계정에 추가합니다.
        //from 주소와 계약 간의 세금 이벤트와 수익 이벤트를 기록합니다.
        if (tax > 0) {
            // Use 1/5 of tax for revenue
            uint revenue = tax / 5;
            tax -= revenue;

            // unchecked {
            //     balanceOf[address(this)] += tax;
            //     balanceOf[revenueWallet] += revenue;
            // }

            balanceOf[address(this)] = uncheckedAdd(balanceOf[address(this)], tax);
            balanceOf[revenueWallet] = uncheckedAdd(balanceOf[revenueWallet], revenue);

            // Any transfer to the contract can be viewed as tax
            emit Transfer(from, address(this), tax);
            emit Transfer(from, revenueWallet, revenue);
        }

        return true;
    }
}