pragma solidity ^0.6.6;

import "./BinaryOptions.sol";
contract FakePriceProvider is AggregatorV3Interface {
    uint256 public price;
    uint8 public override decimals = 8;
    string public override description = "Test implementatiln";
    uint256 public override version = 0;

    constructor(uint256 _price) public {
        price = _price;
    }

    function setPrice(uint256 _price) external {
        price = _price;
    }

    function getRoundData(uint80) external override view returns (uint80, int256, uint256, uint256, uint80) {
        revert("Test implementation");
    }

    function latestAnswer() external view returns(int result) {
        (, result, , , ) = latestRoundData();
    }

    function latestRoundData()
        public
        override
        view
        returns (
            uint80,
            int256 answer,
            uint256,
            uint256,
            uint80
        )
    {
        answer = int(price);
    }
}

