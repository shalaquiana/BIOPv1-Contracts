pragma solidity ^0.6.6;


import "@openzeppelin/contracts/math/SafeMath.sol";
import "./PoolERC20.sol";
import "./LinearBondingCurve.sol";

//import "@chainlink/contracts/src/v0.6/interfaces/AggregatorV3Interface.sol";
interface AggregatorV3Interface {

  function decimals() external view returns (uint8);
  function description() external view returns (string memory);
  function version() external view returns (uint256);

  // getRoundData and latestRoundData should both raise "No data present"
  // if they do not have data to report, instead of returning unset values
  // which could be misinterpreted as actual reported values.
  function getRoundData(uint80 _roundId)
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );

}


contract BinaryOptions {
    using SafeMath for uint256;
    address owner;
    address public poolAddress;
    address public tokenAddress;
    AggregatorV3Interface priceProvider;
    uint256 contractCreationTimestamp;
    Option[] public options;

    /* Types */
    enum OptionType {Invalid, Put, Call}
    enum State {Inactive, Active, Exercised, Expired}
    struct Option {
        State state;
        address payable holder;
        uint256 strikePrice;
        uint256 purchaseAmount;
        uint256 lockedAmount;//purchaseAmount+possible reward for correct bet
        uint256 expiration;
        OptionType optionType;
    }

    /* Events */
     event Create(
        uint256 indexed id,
        address indexed account,
        uint256 strikePrice,
        uint256 lockedValue,
        OptionType direction
    );
    event Exercise(uint256 indexed id);
    event Expire(uint256 indexed id);

    event PriceProviderSet(address pp);
   

     modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

     /**
     * @param pp_ The address of ChainLink ETH/USD price feed contract
     * @param token_ the address of the erc20 token used for trading
     */
    constructor(address pp_, address payable token_) public {
        tokenAddress = token_;
        priceProvider = AggregatorV3Interface(pp_);
        contractCreationTimestamp = block.timestamp;
        owner = msg.sender;
        poolAddress = 0x0000000000000000000000000000000000000000;
        emit PriceProviderSet(pp_);
    }

    function setPoolAddress(address poolAddress_) external {
        require(poolAddress_ != 0x0000000000000000000000000000000000000000 && poolAddress == 0x0000000000000000000000000000000000000000);
        poolAddress = poolAddress_;
    }

    function updateFeePercent(uint256 feePercent_) external onlyOwner {
        require(feePercent_ > 0 && feePercent_ < 30);
        PoolERC20 pool = PoolERC20(poolAddress);
        pool.updateFeePercent(feePercent_);
    }

    function closeStaking() external onlyOwner {
        PoolERC20 pool = PoolERC20(poolAddress);
        pool.closeStaking();
    }

    

    function setOwner(address payable newOwner_) external onlyOwner {
        owner = newOwner_;
    }

     /**
     * @notice Creates a new option
     * @param amount Option amount
     * @param optionType Call or Put option type
     */
    function create(uint256 amount, OptionType optionType)
        external
    {
         LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        require(token.balanceOf(msg.sender) >= amount, "insufficent BIOP balance");
        require(
            optionType == OptionType.Call || optionType == OptionType.Put,
            "Wrong option type"
        );
        uint256 possiblePayout = calculatePossiblePayout(amount);
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 optionID = options.length;

        token.transferFrom(msg.sender, poolAddress, amount);
        Option memory option = Option(
            State.Active,
            msg.sender,
            uint256(latestPrice),
            amount,
            amount.add(possiblePayout),
            block.timestamp + 60 minutes,//options are all 1hr to start
            optionType
        );

        options.push(option);
        PoolERC20 pool = PoolERC20(poolAddress);
        pool.lock(option.lockedAmount);
        emit Create(optionID, msg.sender, uint256(latestPrice), possiblePayout, optionType);
   
        }

     /**
     * @notice exercises a option
     * @param optionID id of the option to exercise
     */
    function exercise(uint256 optionID)
        external
    {
        Option memory option = options[optionID];
        require(block.timestamp <= option.expiration, "expiration date margin has passed");
        (, int256 latestPrice, , , ) = priceProvider.latestRoundData();
        uint256 uLatestPrice = uint256(latestPrice);
        if (option.optionType == OptionType.Call) {
            require(uLatestPrice > option.strikePrice, "price is to low");
        } else {
            require(uLatestPrice < option.strikePrice, "price is to high");
        }

        //option expires ITM, we pay out
        PoolERC20 pool = PoolERC20(poolAddress);
        pool.payout(option.lockedAmount, msg.sender, option.holder);

        emit Exercise(optionID);
    }

     /**
     * @notice expires a option
     * @param optionID id of the option to expire
     */
    function expire(uint256 optionID)
        external
    {
        Option memory option = options[optionID];
        require(block.timestamp > option.expiration, "expiration date has not passed");
        PoolERC20 pool = PoolERC20(poolAddress);
        pool.unlock(option.purchaseAmount, msg.sender);
        emit Expire(optionID);
    }

    /**
     * @notice Calculates maximum option buyer profit
     * @param amount Option amount
     * @return profit total possible profit amount
     */
    function calculatePossiblePayout(uint256 amount)
        public
        view
        returns (uint256)
    {
        PoolERC20 pool = PoolERC20(poolAddress);
        uint256 maxAvailable = pool.getMaxAvailable();
        require(amount <= maxAvailable, "greater then pool funds available");

        uint256 oneTenth = amount.div(10);
        if(oneTenth > 0) {
            return amount.mul(2).sub(oneTenth);
        } else {
            uint256 oneThird = amount.div(3);
            require(oneThird > 0, "invalid bet amount");
            return amount.mul(2).sub(oneThird);
        }
    }

    
}