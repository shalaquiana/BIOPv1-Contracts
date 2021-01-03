const BinaryOptions = artifacts.require("BinaryOptions");
const PoolERC20 = artifacts.require("PoolERC20");
const BondingCurveUniversalToken = artifacts.require("LinearBondingCurve");
const BN = web3.utils.BN;
//fake price provider
const FakePriceProvider = artifacts.require("FakePriceProvider");

const tokenSettings = {
  name: "Biop",
  symbol: "BIOP",
  k: new BN("100830342800"),
  startPrice: new BN("350000000000000"),
  hegicDevAddress: "0xC961AfDcA1c4A2A17eada10D2e89D052bEf74A85",
};

const BinaryOptionsSettings = {
  priceProviderAddress: "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419"//"0x9326BFA02ADD2366b30bacB125260Af641031331" //kovan<- ->mainnet // "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419", //mainnet address
  
};

const PoolERC20Settings = {
  name: "BIOP Pool Shares",
  symbol: "wBIOP",
  feePercent: 5,
};

const FakePriceSettings = {
  price: 753520000000,
};

module.exports = function (deployer) {
  deployer
    .deploy(
      BondingCurveUniversalToken,
      tokenSettings.name,
      tokenSettings.symbol,
      tokenSettings.k,
      tokenSettings.startPrice,
      tokenSettings.hegicDevAddress
    )
    .then((tokenInstance) => {
      console.log("deploy 1 complete");
      console.log(tokenInstance.address);
      /* comment this out for live deploys, the price provider addresses are above
              *//* 
        return deployer
        .deploy(FakePriceProvider, FakePriceSettings.price)
        .then((ppInstance) => {
          console.log("deploy 1.5 complete");
          console.log(ppInstance.address);   */
          return deployer
            .deploy(
              BinaryOptions,
              BinaryOptionsSettings.priceProviderAddress,//ppInstance.address,//
              tokenInstance.address
            )
            .then(async function (BOinstance) {
              console.log("deploy 2 complete");

              return await deployer.deploy(
                PoolERC20,
                PoolERC20Settings.name,
                PoolERC20Settings.symbol,
                tokenInstance.address,
                BOinstance.address,
                PoolERC20Settings.feePercent
              );
            })
            .catch((e) => {
              console.log("caught");
              console.log(e);
            });
/*         });    */
    })
    .catch((e) => {
      console.log("caught");
      console.log(e);
    });
};
