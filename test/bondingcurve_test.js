
const BCContract = artifacts.require("LinearBondingCurve")
const toBN = web3.utils.toBN
const params = {
    BCSupply: toBN("753001000000000000000000000")
}
const toWei = (value) => web3.utils.toWei(value.toString(), "ether");

const fromGweiToWei = (value) => web3.utils.toWei(value.toString(), "Gwei");



contract("LinearBondingCurve", (accounts) => {
    it("Should buy tokens", () => {
      return BCContract.deployed().then(async function (instance) {
       
        await instance.buy(toWei(4000), {value:toWei(90.18)})
        
        assert.equal(
          typeof instance,
          "object",
          "Contract instance does not exist"
        );
      });
    });
    it("should sell", () => {
      return BCContract.deployed().then(async function (instance) {
        await instance.sell(fromGweiToWei(4000));
        
        assert.equal(
          typeof instance,
          "object",
          "underlying token does not exist"
        );
      });
    });
  
  });
  