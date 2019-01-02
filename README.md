# Bitcoin

**
MEMBERS:
    SURBHI JAIN (50949509)

FUNCTIONALITIES IMPLEMENTED:
  1. The project is able to mine coins using the user given threshold(difficulty) Testing the validity of a block and checking if the hash calculated matched with the actual hash for a default time value. Checks if the calculation of hash is getting done right
  2. I have implemented wallets to calculate balances at the end for each user involved in the transactions
  3. check the validity of each block, transaction, and the blockchain as a whole
  4. Mining of the pending transactions is done and the reward balance is giving to the address that mines the block
  5. Transactions are signed using the private key and verified when the blockchain/block is being verified.


DESCRIPTION OF THE TEST CASES:
Test cases are written in bitcoin_test.exs file.
I'm assigning some bitcoins initially to each user for easier calculation purposes.
  
  Test 1: Testing the validity of a block and checking if the hash calculated matched with the actual hash for a default time value. Checks if the calculation of hash is getting done right.  
  
  Test 2: Calculates hash of a block using difficulty 5. It should start with 5 0's. ( number of zeroes should be the same as the difficulty)

  Test 3: Checks if the block module is working fine and the block is getting mined correctly. mine block, update hash and generate hash should be in sync. Tamepring with the block and changing one parameter changes the hash making block invalid.

  Test 4: Tampering with the block to put in a hash in the block makes it invalid.
  
  Test 5: Adding 1 new Transaction to the blockchain and checking the length of the chain and the pending transactions. Should be 2 including Genesis block.
  
  Test 6: Doing 2 transactions, mining the pending transactions and we change the transaction amount of one of the transactions and check the validity of the block mined again. Should be false.
  
  Test 7: Verify the transaction address involved during a transaction with that of the public key of the owner.
  
  Test 8: Verfy if the amount if getting correctly updated by the module.
  
  Test 9: Verifying Blockchain by mining and adding that block to the chain.
  
  Test 10: Verifying if the amounts in a transaction are transferred correctly. The transactions are mined and then we check if our wallet balance matches with the transaction amounts.
  
  Test 11: In addition to the test above, here we also check if the mining reward is received by the owner(public key owner) received the mining reward upon mining the pending transactions.
  
  Test 12: Checking validity of a new block created after mining and performing transactions. Is the new block a valid one is confirmed
  
  Test 13: Here first user1 mines pending transactions. There are 4 users
  A, B, C, D. Initially they have BTC as: A->150.00, B-> 200.00, C-> 250.00 and D-> 300.00. The transactions take place as:
  B->C
  D->A
  mining pending transactions by D
  C->B
  mining pending transactions by C
  D->B
  C->A
  mining pending transactions by C
  At the end the balances in the wallet our calculated and should match with the transaction amount as calculated using numbers.




TO TEST:
    Run the command:  mix test
    this will run all test cases



REFERENCES:
1. Creating a blockchain with Javascript (https://www.youtube.com/watch?v=zVqczFZr124&t=637s)
**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `bitcoin` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:bitcoin, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/bitcoin](https://hexdocs.pm/bitcoin).

