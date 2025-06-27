//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.28; // Specifies the version of Solidity to use, ensuring compatibility and security.

// Importing the console module from Hardhat for debugging purposes.
import "hardhat/console.sol";

contract Token { // Declares a new contract named "Token".
    string public name; // Declares a public variable to store the token's name.
    string public symbol; // Declares a public variable to store the token's symbol (ticker).
    uint256 public decimals = 18; // Sets the default number of decimal places for the token.
    uint256 public totalSupply; // Declares a public variable for the total supply of the token.

    // Mapping to track the balance of each address.
    mapping(address => uint256) public balanceOf; // Maps each address to its token balance.
    // Nested mapping to track allowances for delegated token transfers.
    mapping(address => mapping(address => uint256)) public allowance; // Maps an owner address to a spender address to its allowed token amount.

    // Event emitted (triggered and written to the blockchain) when tokens are transferred from one address to another.
    event Transfer(
        address indexed from, // The sender's address, indexed for easier search in logs.
        address indexed to, // The recipient's address, indexed for easier search in logs.
        uint256 value // The amount of tokens transferred.
    );

    // Event triggered when an approval is granted to spend tokens.
    event Approval(
        address indexed owner, // The address of the token owner granting approval.
        address indexed spender, // The address that is approved to spend the tokens.
        uint256 value // The amount of tokens approved for spending.
    );

    // Constructor to initialize the token with its name, symbol, and total supply.
    constructor(
        string memory _name, // Token name provided at deployment.
        string memory _symbol, // Token symbol provided at deployment.
        uint256 _totalSupply // Total supply of the token provided at deployment.
    ) {
        name = _name; // Sets the token's name to the value provided in the constructor.
        symbol = _symbol; // Sets the token's symbol to the value provided in the constructor.
        totalSupply = _totalSupply * (10**decimals); // Calculates the total supply by multiplying the provided value by 10 raised to the number of decimals.
        balanceOf[msg.sender] = totalSupply; // Assigns the total supply to the account that deployed the contract.
    }

    // Function to transfer tokens to another address.
    function transfer(address _to, uint256 _value)
        public // Specifies that this function can be called externally.
        returns (bool success) // Indicates if the transfer was successful.
    {
        require(balanceOf[msg.sender] >= _value); // Checks that the sender has enough tokens to transfer.

        _transfer(msg.sender, _to, _value); // Calls the internal _transfer function to execute the transfer.

        return true; // Returns true to indicate a successful transfer.
    }

    // Internal function to handle the actual transfer logic.
    function _transfer(
        address _from, // The sender's address.
        address _to, // The recipient's address.
        uint256 _value // The amount of tokens to transfer.
    ) internal { // Specifies that this function can only be called from within this contract or derived contracts.
        require(_to != address(0)); // Ensures that the recipient address is valid (not the zero address).

        balanceOf[_from] = balanceOf[_from] - _value; // Decreases the balance of the sender by the transfer amount.
        balanceOf[_to] = balanceOf[_to] + _value; // Increases the balance of the recipient by the transfer amount.

        emit Transfer(_from, _to, _value); // Emits the Transfer event to log the transaction.
    }

    // Function to approve another address to spend tokens on behalf of the caller.
    function approve(address _spender, uint256 _value)
        public // Specifies that this function can be called externally.
        returns(bool success) // Indicates if the approval was successful.
    {
        require(_spender != address(0)); // Ensures that the spender address is valid (not the zero address).

        allowance[msg.sender][_spender] = _value; // Sets the allowance for the spender to the specified amount.

        emit Approval(msg.sender, _spender, _value); // Emits the Approval event to log the approval.
        return true; // Returns true to indicate a successful approval.
    }

    // Function to transfer tokens from one address to another using the allowance mechanism.
    function transferFrom(
        address _from, // The address from which tokens are being transferred.
        address _to, // The address to which tokens are being transferred.
        uint256 _value // The amount of tokens to transfer.
    )
        public // Specifies that this function can be called externally.
        returns (bool success) // Indicates if the transfer was successful.
    {
        require(_value <= balanceOf[_from]); // Checks that the sender has enough tokens.
        require(_value <= allowance[_from][msg.sender]); // Checks that the caller is allowed to spend the specified amount.

        allowance[_from][msg.sender] = allowance[_from][msg.sender] - _value; // Decreases the allowance for the caller.

        _transfer(_from, _to, _value); // Calls the internal _transfer function to execute the transfer.

        return true; // Returns true to indicate a successful transfer.
    }
}
