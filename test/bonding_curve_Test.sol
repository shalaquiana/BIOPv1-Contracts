pragma solidity ^0.6.6;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LinearBondingCurve.sol";
import "../contracts/BinaryOptions.sol";
import "../contracts/PoolERC20.sol";

contract BondingCurveTest {

  function testBuy() public {
    LinearBondingCurve child = LinearBondingCurve(DeployedAddresses.LinearBondingCurve());
    
    uint256 sold = child.soldAmount();
    uint ethAmount = child.s(sold, sold+100);
    child.buy{value: ethAmount}(100);

    uint ethAmount2 = child.s(100000000, 100000000+10000000);//3500
    

    Assert.equal(uint(address(this).balance), uint(0), "user erc20 shares is 35000");
  }
/* 
  function testSForSell() public {
   LinearBondingCurve child = LinearBondingCurve(DeployedAddresses.LinearBondingCurve());
    
    uint256 sold = child.soldAmount();
    uint ethAmount = child.s(sold, sold+100000000);
    child.buy{value: ethAmount}(100000000);


    uint256 sold2 = child.soldAmount();
    uint256 ethAmount2 = child.s(sold2-1000, sold2);
    uint256 balance1 = child.balanceOf(address(this));
    // child.sell(1000);

    Assert.equal(ethAmount2, address(DeployedAddresses.LinearBondingCurve()).balance, "user erc20 shares is 1000");
  }

  function testSell() public {
   LinearBondingCurve child = LinearBondingCurve(DeployedAddresses.LinearBondingCurve());
    
    uint256 sold = child.soldAmount();
    uint ethAmount = child.s(sold, sold+100000000);
    child.buy{value: ethAmount}(100000000);


    uint256 sold2 = child.soldAmount();
    uint256 ethAmount2 = child.s(sold2-(child.balanceOf(address(this))/2), sold2);
    uint256 balance1 = child.balanceOf(address(this));
    child.sell(child.balanceOf(address(this)));

    Assert.equal(0, address(DeployedAddresses.LinearBondingCurve()).balance, "user balANCE IS NOT 3000");
  }
 */
 /*  function testWithdrawBIOP() public {
    BondingCurveUniversal bcu = BondingCurveUniversal(DeployedAddresses.BondingCurveUniversal());
    
    uint expected = 179900;
    bcu.sell(100);

    Assert.equal(bcu.balanceOf(tx.origin) , expected, "Owner should have  179900 BIOP after selling 100 BIOP");
  } 
  function testWithdrawETHContractBalance() public {
    BondingCurveUniversal bcu = BondingCurveUniversal(DeployedAddresses.BondingCurveUniversal());
    
    uint balance1 = address(bcu).balance;
    uint amountSold = bcu.sell(10000);
    uint balance2 = address(bcu).balance;

    Assert.equal( balance1-amountSold , balance2, "Contract should have less ETH after buying back BIOP");
  } 
  function testWithdrawETHUserBalance() public {
    BondingCurveUniversal bcu = BondingCurveUniversal(DeployedAddresses.BondingCurveUniversal());
    
    uint balance3 = tx.origin.balance;
    uint amountSold = bcu.sell(10000);
    uint balance4 = tx.origin.balance;

    Assert.equal( balance3+amountSold , balance4, "Owner should have more ETH after selling BIOP");
  } 

  function testWithdrawETHAmountRecievedDecrease() public {
    BondingCurveUniversal bcu = BondingCurveUniversal(DeployedAddresses.BondingCurveUniversal());

    uint saleReturn1 = bcu.calculateSaleReturn(bcu.totalSupply(), bcu.poolBalance(), bcu.reserveRatio(), 10000);
    uint amountSold = bcu.sell(100000);
    uint saleReturn2 = bcu.calculateSaleReturn(bcu.totalSupply(), bcu.poolBalance(), bcu.reserveRatio(), 10000);

    Assert.notEqual( saleReturn1 , saleReturn2, "sale amount should decrease as pool balance decreases");
  }  */
}