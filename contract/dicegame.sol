// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

interface IERC20Token {
  function transfer(address, uint256) external returns (bool);
  function approve(address, uint256) external returns (bool);
  function transferFrom(address, address, uint256) external returns (bool);
  function totalSupply() external view returns (uint256);
  function balanceOf(address) external view returns (uint256);
  function allowance(address, address) external view returns (uint256);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
* @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);
    return c;

  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;

  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }

}

contract Casino {
    
    // use safemath to avoid overflows
    using SafeMath for uint256;
    using SafeMath for uint8;
    
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address internal casinoOwner;
    uint internal salt;
    
     // dynamically set owner when contract is deployed and fixed valiues
    constructor(){
        casinoOwner = msg.sender;
        salt = 250;
    }
    
    mapping (address => uint8) internal games;
    
     // allows only the owner of the owner access
    modifier onlyCasinoOwner() {
        require(msg.sender == casinoOwner);
        _;
    }
    
    function playDice(
        uint _amount,
        uint _bet 
    ) public payable {
        games[msg.sender] = randomDiceNumber();
        
        if(uint8(_bet) == games[msg.sender]) {
            require(IERC20Token(cUsdTokenAddress).transfer(msg.sender, _amount.mul(6)), "transfer failed");
        } else {
            require(
                IERC20Token(cUsdTokenAddress).transferFrom(
                    msg.sender,
                    address(this),
                    _amount
                ),
                "Transfer failed."
            );
        }
    }
    
    function getMyLastDiceNumber() public view returns(uint8) {
        return games[msg.sender];
    }
    
    function setSalt(uint _salt) public onlyCasinoOwner{
        salt = _salt;
    }
    
    function withdrawFunds(uint _amount) external onlyCasinoOwner {
        require(_amount <= IERC20Token(cUsdTokenAddress).balanceOf(address(this)));
        require(IERC20Token(cUsdTokenAddress).transfer(msg.sender, _amount));
    }
    
    function depositFunds(uint _amount) external payable {
        require(IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        ), "Transfer failed");
    }
    
    function getCasinoBalance() public view onlyCasinoOwner returns(uint) {
        return IERC20Token(cUsdTokenAddress).balanceOf(address(this));
    }

    function randomDiceNumber() public view returns (uint8) {
        return uint8((randomNumber().mod(6)).add(1));
    }
    
    function randomNumber() public view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, salt))).mod(251));
    }
    
    // allows the current owner of a smart contract to give out ownership to another address
    function transferOwnerShip(address newOwner) public onlyCasinoOwner {
        casinoOwner = newOwner;
    }
}
