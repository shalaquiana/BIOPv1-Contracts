pragma solidity ^0.6.6;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/LinearBondingCurve.sol";
import "../contracts/BinaryOptions.sol";
import "../contracts/PoolERC20.sol";
import "../contracts/FakePriceProvider.sol";

contract BinaryOptionsTest {

  function testCalculatePossiblePayout() public {
    LinearBondingCurve child = LinearBondingCurve(DeployedAddresses.LinearBondingCurve());
    BinaryOptions bo = BinaryOptions(DeployedAddresses.BinaryOptions());
    
    uint ethAmount = child.s(0, 1000);
    child.buy{value: ethAmount}(1000);

    //step 1 se have to put some money in the pool first
    //this stuff is tested in poolerc20_test.sol
    bo.setPoolAddress(DeployedAddresses.PoolERC20());
    PoolERC20 pERC20 = PoolERC20(DeployedAddresses.PoolERC20());
    child.increaseAllowance(address(pERC20), 1000);
    child.increaseAllowance(address(bo), 1000);
    pERC20.stake(500);    
    

    //2 step calc the payour
    uint256 payout = bo.calculatePossiblePayout(100);
    Assert.equal(payout, 190, "possible payout is not 190");
  }
  function poolBalanceStaysSet() public {

    BinaryOptions bo = BinaryOptions(DeployedAddresses.BinaryOptions());
    address poolAddress = bo.poolAddress();


    Assert.equal(poolAddress, address(DeployedAddresses.PoolERC20()), "pool address is not correctly  set");
  }

function testFakePriceExists() public {
    FakePriceProvider pp = FakePriceProvider(DeployedAddresses.FakePriceProvider());
    
        (, int256 latestPrice, , , ) = pp.latestRoundData();

    Assert.equal(latestPrice, 753520000000, "latest price is not 753520000000");
  }

  function poolBalanceSta() public {

    BinaryOptions bo = BinaryOptions(DeployedAddresses.BinaryOptions());
    address poolAddress = bo.poolAddress();


    Assert.equal(poolAddress, address(DeployedAddresses.PoolERC20()), "pool address is not correctly  set");
  }

   function poolhasBalamce() public {

    BinaryOptions bo = BinaryOptions(DeployedAddresses.BinaryOptions());
    address poolAddress = bo.poolAddress();

    PoolERC20 pool = PoolERC20(poolAddress);
    LinearBondingCurve child = LinearBondingCurve(DeployedAddresses.LinearBondingCurve());
    

    uint ethAmount = child.s(0, 1000);
    child.buy{value: ethAmount}(1000);
    child.increaseAllowance(address(poolAddress), 1000);

    pool.stake(500);    
    uint256 balance = child.balanceOf(poolAddress);
    Assert.equal(balance, uint256(0), "poolbalance is not zero");
  }
}