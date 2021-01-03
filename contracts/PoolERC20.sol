pragma solidity ^0.6.6;

import "@openzeppelin/contracts/math/SafeMath.sol";

import "./LinearBondingCurve.sol";


/**
 * @title ERC20 Token Pool
 * @author github.com/Shalquiana
 * @dev Pool ERC20 Tokens administered by BinaryOptions contract
 * Biop
 */
contract PoolERC20 is ERC20 {
    using SafeMath for uint256;
    address payable public tokenAddress;
    address public owner;
    mapping(address=>uint256) public lastStake;
    uint256 public lockedAmount;
    uint256 public feePercent;
    bool public open = true;

    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }


    event Payout(uint256 poolLost, address winner);


    function getMaxAvailable() public view returns(uint256) {
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        uint256 balance = token.balanceOf(address(this));
        if (balance > lockedAmount) {
            return balance.sub(lockedAmount);
        } else {
            return 0;
        }
    }

    constructor(string memory name_, string memory symbol_, address payable token_, address owner_, uint256 feePercent_) public ERC20(name_, symbol_){
        tokenAddress = token_;
        owner = owner_;
        feePercent = feePercent_;
        lockedAmount = 0;
    }

    function thisAddress() public view returns (address){
        return address(this);
    }

    function updateFeePercent(uint256 feePercent_) external onlyOwner {
        require(feePercent_ > 1 && feePercent_ < 50, "invalid fee");
        feePercent = feePercent_;
    }

     /**
     * @dev used to send this pool into EOL mode when a newer one is open
     */
    function closeStaking() external onlyOwner {
        open = false;
    }


    function stake(uint256 amount) external {
        require(open == true, "pool deposits has closed");
        lastStake[msg.sender] = block.timestamp;
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        require(token.balanceOf(msg.sender) >= amount, "You don't have enough of the underlying token");
        token.transferFrom(msg.sender, address(this), amount);
        _mint(msg.sender, amount);
    }

    function withdraw(uint256 amount) public {
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        require(block.timestamp >= lastStake[msg.sender]+14 days, "Incomplete staking time");
        require (balanceOf(msg.sender) >= amount, "Insufficent Share Balance");
        uint256 poolBalance = token.balanceOf(address(this));
        uint256 valueToRecieve = amount.mul(poolBalance).div(totalSupply());
        _burn(msg.sender, amount);
        require(token.transfer(msg.sender, valueToRecieve), "transfer failed");
    }

    /**
    @dev called by BinaryOptions contract to lock pool value coresponding to new binary options bought. 
    @param amount amount in BIOP to lock from the pool total.
    */
    function lock(uint256 amount) external onlyOwner {
        lockedAmount = lockedAmount.add(amount);
    }

    /**
    @dev called by BinaryOptions contract to unlock pool value coresponding to an option expiring otm. 
    @param amount amount in BIOP to unlock
    @param goodSamaritan the user paying to unlock these funds, they recieve a fee
    */
    function unlock(uint256 amount, address goodSamaritan) external onlyOwner {
        require(amount <= lockedAmount, "insufficent pool balance available to unlock");
        lockedAmount = lockedAmount.sub(amount);

        uint256 fee = amount.div(feePercent);
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        token.transfer(goodSamaritan, fee);
    }

    /**
    @dev called by BinaryOptions contract to payout pool value coresponding to binary options expiring itm. 
    @param amount amount in BIOP to unlock
    @param exerciser address calling the exercise/expire function, this may the winner or another user who then earns a fee.
    @param winner address of the winner.
    @notice exerciser fees are subject to change see updateFeePercent above.
    */
    function payout(uint256 amount, address exerciser, address winner) external onlyOwner {
        require(amount <= lockedAmount, "insufficent pool balance available to payout");
        LinearBondingCurve token = LinearBondingCurve(tokenAddress);
        
        require(amount <= token.balanceOf(address(this)), "insufficent balance in pool");
        lockedAmount = lockedAmount.sub(amount);
        if (exerciser != winner && amount.div(feePercent) > 0) {
            //good samaratin fee
            uint256 fee = amount.div(feePercent);
            token.transfer(exerciser, fee);
            token.transfer(winner, amount.sub(fee));
        } else {
            token.transfer(winner, amount);
        }
        emit Payout(amount, winner);
    }


}