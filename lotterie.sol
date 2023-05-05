// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
 // tableau dynamique pour stocker les joueurs
address payable[] public players;
// adresse du propriétaire du contrat
address public owner;
// adresse du dernier gagnant
address public lastWinner;

constructor() {
    // constructeur qui initialise le propriétaire
    owner = msg.sender;
}

function enter() public payable {
    require(msg.value == 1 ether, "You need to send 1 ether to enter the lottery");
     // ajouter l'adresse du joueur à la liste des joueurs
    players.push(payable(msg.sender));
}

// fonction pour générer un nombre aléatoire en utilisant les blocs Ethereum et la longueur de la liste des joueurs
function random() private view returns (uint256) {
    return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
}

function pickWinner() public restricted {
    require(players.length > 0, "There are no players in the lottery");
    // obtenir un index aléatoire dans la liste des joueurs
    uint256 index = random() % players.length;
    // récupérer l'adresse du gagnant
    address payable winner = players[index];
    // transférer le solde actuel du contrat au gagnant
    winner.transfer(address(this).balance);
    // transférer l'adresse du gagnant dans lastWinner
    lastWinner = winner;
    // réinitialiser le tableau des participants
    players = new address payable[](0);
    // émettre un événement avec l'adresse du gagnant
    emit Winner(winner);
}

// modificateur pour restreindre l'accès à la fonction pickWinner() au propriétaire du contrat
modifier restricted() {
    require(msg.sender == owner, "Only the owner can pick a winner");
    _;
}

// événement qui est émis à chaque fois qu'un gagnant est choisi
event Winner(address winner);
}
