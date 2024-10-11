// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

// Import the Token contract, which represents the token being sold in this crowdsale.
import "hardhat/console.sol";
import "./Token.sol";

// Crowdsale contract for selling tokens to users.
contract Crowdsale_exp {
    // Contract variables
    address owner;          // Address of the contract owner (deployer of the contract)
    Token public token;     // Token contract that the crowdsale will sell
    uint256 public price;   // Price per token (in wei)
    uint256 public maxTokens;// Maximum number of tokens available for sale
    uint256 public tokensSold; // Tracks how many tokens have been sold during the crowdsale

    // Events that are emitted during certain actions
    event Buy(uint256 amount, address buyer);  // Triggered when tokens are bought
    event Finalize(uint256 tokensSold, uint256 ethRaised);  // Triggered when crowdsale is finalized

    // Constructor sets the initial values for the crowdsale
    constructor(
        Token _token,          // The token contract instance
        uint256 _price,        // Initial price per token
        uint256 _maxTokens     // Maximum number of tokens available for sale
    ) {
        owner = msg.sender;    // The deployer of the contract becomes the owner
        token = _token;        // Assign the token contract
        price = _price;        // Set the price of tokens
        maxTokens = _maxTokens;// Set the maximum tokens available for sale
    }

    // Modifier to restrict access to only the contract owner
    modifier onlyOwner() {

        // ???? This acts as an if then statment? ????
        require(msg.sender == owner, "Caller is not the owner");  // Ensure the caller is the owner 
        _; // Continue execution of the function 
    }

    // Fallback function to handle incoming ETH directly to the contract.
    // If someone sends ETH to the contract without calling a function,
    // they will automatically buy tokens.
    receive() external payable {
        uint256 amount = msg.value / price;  // Calculate the number of tokens to buy based on the amount of ETH sent
        buyTokens(amount * 1e18);            // Call the `buyTokens` function to complete the purchase
    }

    // Function to buy tokens by sending a specific amount of ETH.
    function buyTokens(uint256 _amount) public payable {
        require(msg.value == (_amount / 1e18) * price);    // Check that the correct amount of ETH is sent
        require(token.balanceOf(address(this)) >= _amount); // Ensure the contract has enough tokens for sale
        require(token.transfer(msg.sender, _amount));      // Transfer the purchased tokens to the buyer

        tokensSold += _amount;  // Update the number of tokens sold

        emit Buy(_amount, msg.sender);  // Emit an event signaling the purchase
    }

    // Function to allow the owner to change the price of tokens
    function setPrice(uint256 _price) public onlyOwner {
        price = _price;  // Update the price of tokens
    }

    // Function to finalize the crowdsale and send the remaining tokens and ETH to the owner.
    function finalize() public onlyOwner {
        // Transfer any remaining tokens in the contract back to the owner
        require(token.transfer(owner, token.balanceOf(address(this))));

        // Transfer all the ETH (raised during the crowdsale) to the owner
        uint256 value = address(this).balance;
        (bool sent, ) = owner.call{value: value}("");  // Send ETH to the owner's address
        require(sent);  // Ensure the ETH transfer was successful

        // Emit an event signaling the end of the crowdsale and the amount of ETH raised
        emit Finalize(tokensSold, value);
    }
}
