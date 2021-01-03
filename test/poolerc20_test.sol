pragma solidity ^0.6.6;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LinearBondingCurve.sol";
import "../contracts/BinaryOptions.sol";
import "../contracts/PoolERC20.sol";

contract PoolERC20Test {
  function testInitialBalanceUsingDeployedContract() public {
    PoolERC20 pERC20 = PoolERC20(DeployedAddresses.PoolERC20());

    uint expected = 0;

    Assert.equal(pERC20.balanceOf(tx.origin), expected, "Owner should have 0 shares initially");
  }

  event Loaded(address contractLoaded);

  function testDeposit() public {
    LinearBondingCurve child = LinearBondingCurve(DeployedAddresses.LinearBondingCurve());
    BinaryOptions bo = BinaryOptions(DeployedAddresses.BinaryOptions());
    bo.setPoolAddress(DeployedAddresses.PoolERC20());
    PoolERC20 pERC20 = PoolERC20(DeployedAddresses.PoolERC20());
    uint ethAmount = child.s(0, 1000);
    child.buy{value: ethAmount}(1000);

    

    //2 step process. needed so pERC transferFrom call will succeed
    child.increaseAllowance(address(pERC20), 1000);
    child.increaseAllowance(address(bo), 1000);
    pERC20.stake(1000);
    Assert.equal(pERC20.balanceOf(address(this)), 1000, "user erc20 shares is 1000");
  }

  function testWithdraw() public {
    PoolERC20 pERC20 = PoolERC20(DeployedAddresses.PoolERC20());

    //we already have made a deposit in the previous testDeposit function
    //it should not allow withdraw as it just happened

    bool r;
    (r, ) = address(pERC20).call(abi.encodePacked(pERC20.withdraw.selector, uint256(1000)));
    Assert.isFalse(r, "immediate withdraw did not fail!");
  
  }

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