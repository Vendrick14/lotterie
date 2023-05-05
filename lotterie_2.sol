// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Lottery {
 // tableau dynamique pour stocker les joueurs
address payable[] public players;
// adresse du propriétaire du contrat
address public owner;
// Mappage entre les adresses des joueurs et leur montant misé
mapping(address => uint256) public playerBetAmounts;
// Nouvelle variable pour stocker le dernier gagnant
address payable public lastWinner; 
// Nouvelle variable pour stocker le montant gagné par le dernier gagnant
uint256 public lastWinningAmount; 

// Constructeur du contrat
constructor() {
    // Stocke l'adresse du déploiement comme propriétaire
    owner = payable(msg.sender);
}

// Fonction pour participer à la loterie
function enter() public payable {
    // Vérifie que le joueur a envoyé une somme non nulle
    require(msg.value > 0, "You need to send some ether to enter the lottery");
    // Ajoute l'adresse du joueur au tableau des joueurs
    players.push(payable(msg.sender));
    // Incrémente le montant misé par le joueur
    playerBetAmounts[msg.sender] += msg.value;
}

// Fonction pour générer un nombre aléatoire
function random() private view returns (uint256) {
    // Utilise le hash d'un certain nombre de paramètres pour générer un nombre aléatoire
    return uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
}

// Fonction pour désigner un gagnant
function pickWinner() public restricted {
    // Vérifie qu'il y a des joueurs dans la loterie
    require(players.length > 0, "There are no players in the lottery");
    // Calcule le montant total misé dans la loterie
    uint256 totalBetAmount = address(this).balance;
    // Génère un nombre aléatoire compris entre 0 et le montant total misé
    uint256 winningNumber = random() % totalBetAmount;
    // Variable pour stocker le montant accumulé des mises des joueurs
    uint256 accumulatedAmount = 0;
    // Adresse du gagnant
    address payable winner;
    // Parcours le tableau des joueurs et détermine le gagnant
    for (uint256 i = 0; i < players.length; i++) {
        // Ajoute la mise du joueur actuel au montant accumulé
        accumulatedAmount += playerBetAmounts[players[i]];
        // Si le montant accumulé est supérieur ou égal au nombre aléatoire,
        // le joueur actuel est le gagnant
        if (accumulatedAmount >= winningNumber) {
            winner = players[i];
            break;
        }
    }
    // Stocke l'adresse du dernier gagnant
    lastWinner = winner;
    // Stocke le montant gagné par le dernier gagnant
    lastWinningAmount = totalBetAmount;
    // Transfère le montant total misé au gagnant
    winner.transfer(totalBetAmount);
    // Réinitialise le tableau des joueurs
    players = new address payable[](0);
    // Émet un événement pour indiquer le gagnant et le montant gagné
    emit Winner(winner, totalBetAmount);
}

// modificateur pour restreindre l'accès à la fonction pickWinner() au propriétaire du contrat
modifier restricted() {
    require(msg.sender == owner, "Only the owner can pick a winner");
    _;
}

// événement qui est émis à chaque fois qu'un gagnant est choisi
event Winner(address indexed winner, uint256 amount);
}
