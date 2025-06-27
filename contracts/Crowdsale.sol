//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.28;

// Importing the console module from Hardhat for debugging purposes.
import "hardhat/console.sol";
import "./Token.sol"; // Importing the Token contract for use in the Crowdsale contract.

// Crowdsale contract
contract Crowdsale {
    address owner; // Owner of the crowdsale
    Token public token; // Token being sold
    uint256 public price; // Price in wei
    uint256 public maxTokens; // Maximum tokens for sale
    uint256 public tokensSold; // Tokens sold tracker

    // Events
    event Buy(uint256 amount, address buyer); // Event emitted when tokens are bought
    event Finalize(uint256 tokensSold, uint256 ethRaised); // Event emitted when the crowdsale is finalized


    // Constructor
    constructor(
        Token _token, // Token being sold. Using the "_token" convention for internal contract use then updating the state variable to "token".
        uint256 _price, // Price in wei. Using the "_price" convention for internal contract use then updating the state variable to "price".
        uint256 _maxTokens // Maximum tokens for sale. Using the "_maxTokens" convention for internal contract use then updating the state variable to "maxTokens".
    ) {
        owner = msg.sender; // Sets the owner of the crowdsale to the address that deployed the contract.
        token = _token; // Sets the token being sold to the token provided in the constructor.
        price = _price; // Sets the price of the token to the price provided in the constructor.
        maxTokens = _maxTokens; // Sets the maximum tokens for sale to the maximum tokens provided in the constructor.
    }

    modifier onlyOwner() { // Modifier to check if the caller is the owner of the crowdsale.
        require(msg.sender == owner, "Caller is not the owner"); // Require statement to check that the caller is the owner of the crowdsale.
        _;
    }

    // Buy tokens directly by sending Ether
    // --> https://docs.soliditylang.org/en/v0.8.15/contracts.html#receive-ether-function

    receive() external payable { // Receive function is called when Ether is sent to the contract.
        uint256 amount = msg.value / price; // Calculates the amount of tokens to buy based on the price and the amount of Ether sent.
        buyTokens(amount * 1e18); // Calls the buyTokens function to buy the calculated amount of tokens.
    }

    // Buy tokens by calling this function
    function buyTokens(uint256 _amount) public payable { 
        require(msg.value == (_amount / 1e18) * price); // Checks that the amount of Ether sent is equal to the amount of tokens being bought.
        require(token.balanceOf(address(this)) >= _amount); // Checks that the contract has enough tokens to sell.
        require(token.transfer(msg.sender, _amount)); // Transfers the tokens to the buyer.

        tokensSold += _amount; // Increases the tokens sold tracker by the amount of tokens bought.

        emit Buy(_amount, msg.sender); // Emits the Buy event to log the purchase.
    }


    // Set the price
    function setPrice(uint256 _price) public onlyOwner {
        price = _price; // Sets the price of the token to the price provided.
    }

    // Finalize Sale
    function finalize() public onlyOwner {
        require(token.transfer(owner, token.balanceOf(address(this)))); // Transfers the remaining tokens not sold to the owner.

        uint256 value = address(this).balance; // Gets the balance of the tokens in the contract that were not sold.
        (bool sent, ) = owner.call{value: value}(""); // Sends the Ether in the contract earned from the sale to the owner.
        require(sent); // Requires that the Ether was sent successfully.

        emit Finalize(tokensSold, value); // Emits the Finalize event to log the finalization of the sale.
    }
}
