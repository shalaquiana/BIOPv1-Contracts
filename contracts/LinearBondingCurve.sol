pragma solidity ^0.6.6;



import "@openzeppelin/contracts/math/SafeMath.sol";

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";

import "@openzeppelin/contracts/access/Ownable.sol";






/**
 * @title Universal Bonding Curve
 * @author github.com/Shalquiana based heavily on the work of Molly Wintermute
 * @dev Bonding curve ERC20 Token based on linear formula
 * inspired by Hegic.co
 */
contract LinearBondingCurve is ERC20{
  address payable devFund;
  address payable hegic;
  using SafeMath for uint;
  //using SafeERC20 for IERC20;
  //IERC20 token;
  
  uint internal immutable K;
  uint internal immutable START_PRICE;
  uint public soldAmount;
  
  event Bought(address indexed account, uint amount, uint ethAmount);
  event Sold(address indexed account, uint amount, uint ethAmount, uint comission);

  constructor (string memory name_, string memory symbol_, uint k, uint startPrice, address payable hegic_) public ERC20(name_, symbol_){
    K = k;
    START_PRICE = startPrice;
    devFund = msg.sender;
    //token = new ERC20(name_, symbol_);
    hegic = hegic_;
    _setupDecimals(9);
  }

  function buy(uint tokenAmount) external payable {
     uint nextSold = soldAmount.add(tokenAmount);
     uint ethAmount = s(soldAmount, nextSold);
     
     require(msg.value >= ethAmount, "Value is to small");
     _mint(msg.sender, tokenAmount);
     if (msg.value > ethAmount) {
         msg.sender.transfer(msg.value - ethAmount);
     }
     soldAmount = nextSold;
     emit Bought(msg.sender, tokenAmount, ethAmount);
  }
  
 
  function sell(uint tokenAmount) external {
     uint nextSold = soldAmount.sub(tokenAmount);
     uint ethAmount = s(nextSold, soldAmount);
     uint comission = ethAmount.div(10);
     uint refund = ethAmount.sub(comission);
     require(balanceOf(msg.sender) >= tokenAmount, "insufficent balance");
     require(comission > 0);
     uint hegicComission = comission.div(10);
     soldAmount = nextSold;
     _burn(msg.sender, tokenAmount);
     msg.sender.transfer(refund);
     
     
     if (hegicComission > 0) {
        devFund.transfer(comission.sub(hegicComission));
        hegic.transfer(hegicComission);
     } else {
        devFund.transfer(comission);
     } 
    
     emit Sold(msg.sender, tokenAmount, refund, comission);
    }

  

    function s(uint x0, uint x1) public view returns (uint) {
        require (x1 > x0, "invalid formula amounts");
        return  x1.add(x0).mul(x1.sub(x0))
            .div(2).div(K)
            .add(START_PRICE.mul(x1 - x0))
            .div(1e18);
    }
}