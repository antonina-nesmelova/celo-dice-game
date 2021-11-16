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

contract Casino {
    address internal cUsdTokenAddress = 0x874069Fa1Eb16D44d622F2e0Ca25eeA172369bC1;
    address internal casinoOwner = 0xaC5521ED700507C121256aA19c0c6b398cA46868;
    uint internal salt = 250;
    
    mapping (address => uint8) internal games;
    
    function playDice(
        uint _amount,
        uint _bet 
    ) public payable {
        games[msg.sender] = randomDiceNumber();
        
        if(uint8(_bet) == games[msg.sender]) {
            IERC20Token(cUsdTokenAddress).transfer(msg.sender, _amount * 6);
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
    
    function setSalt(uint _salt) public {
        require(msg.sender == casinoOwner);
        salt = _salt;
    }
    
    function withdrawFunds(uint _amount) external {
        require(msg.sender == casinoOwner);
        require(_amount <= IERC20Token(cUsdTokenAddress).balanceOf(address(this)));
        IERC20Token(cUsdTokenAddress).transfer(msg.sender, _amount);
    }
    
    function depositFunds(uint _amount) external payable {
        IERC20Token(cUsdTokenAddress).transferFrom(
            msg.sender,
            address(this),
            _amount
        );
    }
    
    function getCasinoBalance() public view returns(uint) {
        require(msg.sender == casinoOwner);
        return IERC20Token(cUsdTokenAddress).balanceOf(address(this));
    }

    function randomDiceNumber() public view returns (uint8) {
        return (randomNumber() % 6) + 1;
    }
    
    function randomNumber() public view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, salt)))%251);
    }
}