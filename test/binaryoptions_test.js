var BinaryOptions = artifacts.require("BinaryOptions");
const BCContract = artifacts.require("LinearBondingCurve");
var PoolERC20 = artifacts.require("PoolERC20");
var FakePriceProvider = artifacts.require("FakePriceProvider");

const toWei = (value) => web3.utils.toWei(value.toString(), "ether");

contract("BinaryOptions", (accounts) => {
  it("exists", () => {
    return BinaryOptions.deployed().then(async function (instance) {
      assert.equal(
        typeof instance,
        "object",
        "Contract instance does not exist"
      );
    });
  });
  it("Owns the PoolERC20 contract", () => {
    return PoolERC20.deployed().then(function (pool) {
      return BinaryOptions.deployed().then(async function (erc20) {
        var address = await pool.owner.call();
        assert.equal(address, BinaryOptions.address, "incorrect pool owner");
      });
    });
  });
  it("has a poolAddress variable", () => {
    return BinaryOptions.deployed().then(async function (bo) {
      var address = await bo.poolAddress.call();
      console.log(`poolAddress: ${address}`);
      assert.notEqual(address, BinaryOptions.address, "poolAddress not set");
    });
  });

  it("buy an put option and exercise it", () => {
    return BinaryOptions.deployed().then(async function (bo) {
      return BCContract.deployed().then(async function (curve) {
        return PoolERC20.deployed().then(async function (pool) {
          return FakePriceProvider.deployed().then(async function (pp) {
            await bo.setPoolAddress(pool.address);
            await curve.buy(toWei(4000), {
              value: toWei(90.18, { from: accounts[0] }),
            });
            await curve.approve(bo.address, 4000, { from: accounts[0] });
            await curve.approve(pool.address, 4000, { from: accounts[0] });
            
            /* var payout = await bo.calculatePossiblePayout(2000);
      console.log(`payout ${payout}`); */
            await pool.stake(1000, {from: accounts[0]});
            var option = await bo.create(100, 1, { from: accounts[0] });
            console.log(`poolAddress: ${option}`);
            var oldPrice = await pp.latestAnswer();
            await pp.setPrice(oldPrice-10);
            

            await bo.exercise(0);
            assert.equal(
              typeof bo,
              "object",
              "underlying token does not exist"
            );
          });
        });
      });
    });
  });

  it("buy an call option and exercise it", () => {
    return BinaryOptions.deployed().then(async function (bo) {
      return BCContract.deployed().then(async function (curve) {
        return PoolERC20.deployed().then(async function (pool) {
          return FakePriceProvider.deployed().then(async function (pp) {
// await bo.setPoolAddress(pool.address);
            await curve.buy(toWei(4000), {
              value: toWei(90.18, { from: accounts[0] }),
            });
            await curve.approve(bo.address, 4000, { from: accounts[0] });
            await curve.approve(pool.address, 4000, { from: accounts[0] });
            
            /* var payout = await bo.calculatePossiblePayout(2000);
      console.log(`payout ${payout}`); */
            await pool.stake(1000, {from: accounts[0]});
            var option = await bo.create(100, 2, { from: accounts[0] });
            console.log(`poolAddress: ${option}`);
            var oldPrice = await pp.latestAnswer();
            await pp.setPrice(oldPrice+100);
            

            await bo.exercise(1);
            assert.equal(
              typeof bo,
              "object",
              "underlying token does not exist"
            );
          });
        });
      });
    });
  });
});
