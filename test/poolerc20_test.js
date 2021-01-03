var LinearBondingCurve = artifacts.require("LinearBondingCurve");
var PoolERC20 = artifacts.require("PoolERC20");



contract("PoolERC20", (accounts) => {
  it("exists", () => {
    return PoolERC20.deployed().then(async function (instance) {
      assert.equal(
        typeof instance,
        "object",
        "Contract instance does not exist"
      );
    });
  });
  it("LinearBondingCurve token exists", () => {
    return LinearBondingCurve.deployed().then(async function (instance) {
      assert.equal(
        typeof instance,
        "object",
        "underlying token does not exist"
      );
    });
  });

  it("lbc token is the one attached to pool", () => {
    return PoolERC20.deployed().then(function (pool) {
      return LinearBondingCurve.deployed().then(async function (lbc) {
        var address = await pool.tokenAddress.call();
        assert.equal(
          address,
          lbc.address,
          "underlying token not used in pool"
        );
      });
    });
  });
  it("initial total supply is 0", () => {
    return PoolERC20.deployed()
      .then(function (instance) {
        return instance.totalSupply.call();
      })
      .then(function (totalSupply) {
        assert.equal(totalSupply.words[0], 0, "totalSupply was not 0");
      });
  });
 /*  it("supply increases proportionate to amount sent", () => {
    return PoolERC20.deployed().then(function (instance) {
      return ERC20Child.deployed().then(async function (erc20) {
        //first we need some of the underlying token somehow...
        await erc20.create.call(100, {from: accounts[0]});

        var underlying = await erc20.balanceOf(accounts[0]);
        console.log(`has underlying ${underlying.words[0]} tokens`);

        await instance.stake.call(100);

        var balance = await instance.balanceOf(accounts[0]);

        assert.equal(balance.words[0], 0, "Invalid share balance");
      });
    });
  }); */
  /*  it("inital total supply is 180000", () => {
    return BondingCurveUniversal.deployed()
      .then(function (instance) {
        return instance.totalSupply.call();
      })
      .then(function (totalSupply) {
        assert.equal(totalSupply.words[0], 180000, "totalSupply was not 180000");
      });
  });
  it("should give owner initial balance 180000 BIOP", () => {
    return BondingCurveUniversal.deployed()
      .then(async function (instance) {
        //await instance.buy({from: accounts[1],value: web3.utils.toWei('0.11', 'ether')});
        return instance.balanceOf.call(accounts[0]);
      })
      .then(function (balance) {
        assert.equal(balance.words[0], 180000, "owner balance is not 180000");
      });
  });
  */
});
