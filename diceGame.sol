// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

contract DiceGame {
    uint internal salt = 250;

    function randomDiceNumber() public view returns (uint8) {
        return (randomNumber() % 6) + 1;
    }
    
    function randomNumber() public view returns (uint8) {
        return uint8(uint256(keccak256(abi.encodePacked(block.timestamp,
                                          block.difficulty,
                                          salt)))%251);
    }
}
