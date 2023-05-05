// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
    address payable[] public players;
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function enter() public payable {
        require(msg.value == 1 ether, "You need to send 1 ether to enter the lottery");
        players.push(payable(msg.sender));
    }

    function random() private view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    }

    function pickWinner() public restricted {
        require(players.length > 0, "There are no players in the lottery");
        uint256 index = random() % players.length;
        address payable winner = players[index];
        winner.transfer(address(this).balance);
        players = new address payable[](0);
        emit Winner(winner);
    }

    modifier restricted() {
        require(msg.sender == owner, "Only the owner can pick a winner");
        _;
    }

    event Winner(address winner);
}
