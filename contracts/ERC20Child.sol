pragma solidity ^0.6.6;


//load erc20 compatible token 
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ERC20Child is ERC20{
    ERC20 token;
    
    constructor (string memory name_, string memory symbol_) public ERC20(name_, symbol_) {
    }

    function create(uint256 amount) public {
        _mint(msg.sender, amount);
    }

}