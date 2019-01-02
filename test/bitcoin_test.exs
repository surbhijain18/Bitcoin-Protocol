defmodule BitcoinTest do
  use ExUnit.Case
  doctest Bitcoin

  test "test1" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 1: Testing validity of a block hashing"
    {:ok, block} = Block.start_link(0)
    hash = Block.getHash(block)
    IO.inspect assert hash == "F1534392279BDDBF9D43DDE8701CB5BE14B82F76EC6607BF8D6AD557F60F304E"
  end

  test "test 2" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 2: check hash of the block with difficulty 5(begins with 5 0's)"
    {:ok, block} = Block.start_link(:erlang.system_time(:millisecond))
    prev = Block.getPreviousHash(block)
    time = Block.getTimeStamp(block)
    trans = List.to_string(Block.getTransaction(block))
    nonce = Block.getNonce(block)
    hash = Block.generateHash(5, block, prev, time, trans, nonce)
    IO.puts hash
    IO.inspect assert String.starts_with?(hash, "00000") == true
  end

  test "test3" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 3: Check if block is getting mined"
    {:ok, block} = Block.start_link(:erlang.system_time(:millisecond))
    #  hash = Block.calculateHash(time)
    Block.mineBlock(block,2)
    hash2 = Block.getHash(block)

    hash1 = Block.generateHash(2, block, Block.getPreviousHash(block), :erlang.system_time(:millisecond) ,List.to_string(Block.getTransaction(block)), Block.getNonce(block))
    Block.addHashtoBlock(block,hash1 )
    hash = Block.getHash(block)
    IO.inspect assert hash != hash2
 end

 test "test4" do
  IO.puts "__________________________________________________________"
  IO.puts "Test 4: Tampering to check change in hash"
    {:ok, block} = Block.start_link(:erlang.system_time(:millisecond))
    #  hash = Block.calculateHash(time)
    Block.mineBlock(block,2)
    hash2 = Block.getHash(block)

    Block.addHashtoBlock(block, "00D577A719A6EEF26049FAF6B5A2D331BD09707122AAA127FA98D1BC74C1A098")
    hash = Block.getHash(block)

    IO.inspect assert hash != hash2
  end

  test "test5" do
    IO.puts "__________________________________________________________"
    IO.puts "Test5: add new transaction to blockchain"
    {:ok, btc} = Bitcoin.start_link()
    {:ok, user1} = Owner.start_link(0.0)
    {:ok, user2} = Owner.start_link(0.0)
    Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user1), 1)
    {:ok, tid1} = Transaction.start_link(Owner.getPublicKey(user1), Owner.getPublicKey(user2), 100.00)
    Owner.signTransaction(user1, tid1)
    Bitcoin.addTransaction(btc, tid1)
    IO.inspect assert Kernel.length(Bitcoin.getPendingTrns(btc)) == 2
    IO.inspect assert Kernel.length(Bitcoin.getChain(btc)) == 2

  end

  test "test6" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 6: Tampering with transaction and checking block validity"
    {:ok, btc} = Bitcoin.start_link()
    {:ok, user1} = Owner.start_link(0.0)
    {:ok, user2} = Owner.start_link(0.0)
    Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user1), 1)
    {:ok, tid1} = Transaction.start_link(Owner.getPublicKey(user1), Owner.getPublicKey(user2), 100.00)
    Owner.signTransaction(user1, tid1)
    Bitcoin.addTransaction(btc, tid1)

    {:ok, tid2} = Transaction.start_link(Owner.getPublicKey(user2), Owner.getPublicKey(user1), 100.00)
    Owner.signTransaction(user2, tid2)
    Bitcoin.addTransaction(btc, tid2)
    newBlock1 = Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user2), 1)
    IO.inspect assert Block.isBlockValid(newBlock1) == true
    Transaction.setAmount(tid2, 75.00)
    IO.inspect assert Block.isBlockValid(newBlock1) == false
  end

  test "test7" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 7: Verifying transaction addresses"
    {:ok, user1} = Owner.start_link(0.0)
    {:ok, user2} = Owner.start_link(0.0)
    {:ok, tid1} = Transaction.start_link(Owner.getPublicKey(user1), Owner.getPublicKey(user2), 100.00)
    IO.inspect assert Transaction.getFromAddress(tid1) == Owner.getPublicKey(user1)
    IO.inspect assert Transaction.getToAddress(tid1) == Owner.getPublicKey(user2)

  end

  test "test8" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 8: Verify if amount for a transaction is getting updated correctly "
    {:ok, user1} = Owner.start_link(0.0)
    {:ok, user2} = Owner.start_link(0.0)
    {:ok, tid1} = Transaction.start_link(Owner.getPublicKey(user1), Owner.getPublicKey(user2), 100.00)
    {:ok, tid2} = Transaction.start_link(Owner.getPublicKey(user1), Owner.getPublicKey(user2), 70.00)
    IO.inspect assert Transaction.getAmount(tid1) == 100.00
    IO.inspect assert Transaction.getAmount(tid2) == 70.00

  end

  test "test9" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 9: Verifying blockchain"
    {:ok, btc } = Bitcoin.start_link()
    {:ok, user1} = Owner.start_link(0.0)
    bl = Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user1), 1)
    IO.puts assert Block.isBlockValid(bl) == true
    Bitcoin.addBlock(btc,bl)
    IO.puts assert Bitcoin.isChainValid(btc) == false #as its not mined yet.


   end


  test "test10" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 10: Verifying if the amounts in a transaction are transferred correctly "
    {:ok, btc } = Bitcoin.start_link()
    {:ok, user1} = Owner.start_link(200.00)
    {:ok, user2} = Owner.start_link(200.00)
    {:ok, tid1} = Transaction.start_link(Owner.getPublicKey(user1), Owner.getPublicKey(user2), 50.00)
    Owner.signTransaction(user1, tid1)
    Bitcoin.addTransaction(btc, tid1)
    {:ok, tid2} = Transaction.start_link(Owner.getPublicKey(user2), Owner.getPublicKey(user1), 100.00)
    Owner.signTransaction(user2, tid2)
    Bitcoin.addTransaction(btc, tid2)
    IO.puts assert Owner.getAmount(user1) == 200.00 and Owner.getAmount(user2) == 200.00
    Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user2), 2)
    IO.puts assert Bitcoin.getwalletBalance(btc, user1) == 200.00 -50.00 + 100.00
    IO.puts assert Bitcoin.getwalletBalance(btc, user2) == 200.00 +50.00 - 100.00
  end

  test "test11" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 11: Verifying if mining reward is received correctly"
    {:ok, btc } = Bitcoin.start_link()
    {:ok, user1} = Owner.start_link(200.00)
    {:ok, user2} = Owner.start_link(200.00)
    {:ok, user3} = Owner.start_link(0.00) #to receive miming reward
    {:ok, tid1} = Transaction.start_link(Owner.getPublicKey(user1), Owner.getPublicKey(user2), 50.00)
    Owner.signTransaction(user1, tid1)
    Bitcoin.addTransaction(btc, tid1)
    {:ok, tid2} = Transaction.start_link(Owner.getPublicKey(user2), Owner.getPublicKey(user1), 100.00)
    Owner.signTransaction(user2, tid2)
    Bitcoin.addTransaction(btc, tid2)
    block = Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user3), 2)
    Bitcoin.addBlock(btc, block)
    IO.puts assert Bitcoin.getwalletBalance(btc, user3) == 0.00 #before mining
    # IO.puts "         user1-> BTC #{Bitcoin.getwalletBalance(btc, user1)} "
    # IO.puts "         user2-> BTC #{Bitcoin.getwalletBalance(btc, user2)} "
    # IO.puts assert Bitcoin.getwalletBalance(btc, user1) == 250.00 and Bitcoin.getwalletBalance(btc, user2) == 150.00
    Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user3), 2)
    # IO.puts "         user3-> BTC #{Bitcoin.getwalletBalance(btc, user3)} "
    IO.puts assert Bitcoin.getwalletBalance(btc, user3) == 100.00 #after mining

  end

  test "test12" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 12:  Checking validity of a new block created after mining"
    {:ok, btc } = Bitcoin.start_link()
    {:ok, user1} = Owner.start_link(10.00)
    {:ok, user2} = Owner.start_link(10.00)
    Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user1), 2)
    {:ok, tid1} = Transaction.start_link(Owner.getPublicKey(user1), Owner.getPublicKey(user2), 5.00)
    Owner.signTransaction(user1, tid1)
    Bitcoin.addTransaction(btc, tid1)
    {:ok, tid2} = Transaction.start_link(Owner.getPublicKey(user2), Owner.getPublicKey(user1), 4.00)
    Owner.signTransaction(user2, tid2)
    Bitcoin.addTransaction(btc, tid2)
    block = Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user1), 2)
    IO.puts assert Block.isBlockValid(block)
  end

  test "test13-functional testing" do
    IO.puts "__________________________________________________________"
    IO.puts "Test 13:  Checking the complete functioning of bitcoin project"
    difficulty = 2
    {:ok, btc} = Bitcoin.start_link()
    {:ok, user1} = Owner.start_link(150.00)
    {:ok, user2} = Owner.start_link(200.00)
    {:ok, user3} = Owner.start_link(250.00)
    {:ok, user4} = Owner.start_link(300.00)
    IO.puts "Initial Balances: "
    IO.puts "         user1-> BTC #{Owner.getAmount(user1)} "
    IO.puts "         user2-> BTC #{Owner.getAmount(user2)} "
    IO.puts "         user3-> BTC #{Owner.getAmount(user3)} "
    IO.puts "         user4-> BTC #{Owner.getAmount(user4)} "
    Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user1), difficulty)


    {:ok, tid1} = Transaction.start_link(Owner.getPublicKey(user2), Owner.getPublicKey(user3), 50.00)
    Owner.signTransaction(user2, tid1)
    Bitcoin.addTransaction(btc, tid1)

    {:ok, tid2} = Transaction.start_link(Owner.getPublicKey(user4), Owner.getPublicKey(user1), 50.00)
    Owner.signTransaction(user4, tid2)
    Bitcoin.addTransaction(btc, tid2)

    block1 = Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user4), difficulty)

    # IO.puts "After 2 transactions balances are: "
    # IO.puts "         user1-> BTC #{Bitcoin.getwalletBalance(btc, user1)} "
    # IO.puts "         user2-> BTC #{Bitcoin.getwalletBalance(btc, user2)} "
    # IO.puts "         user3-> BTC #{Bitcoin.getwalletBalance(btc, user3)} "
    # IO.puts "         user4-> BTC #{Bitcoin.getwalletBalance(btc, user4)} "
    IO.puts assert Bitcoin.getwalletBalance(btc, user1) == 150.00 + 50.00 + 100.00 #mining reward
    IO.puts assert Bitcoin.getwalletBalance(btc, user2) == 200.00 - 50.00
    IO.puts assert Bitcoin.getwalletBalance(btc, user3) == 250.00 + 50.00
    IO.puts assert Bitcoin.getwalletBalance(btc, user4) == 300.00 - 50.00

    {:ok, tid3} = Transaction.start_link(Owner.getPublicKey(user3), Owner.getPublicKey(user2), 50.00)
    Owner.signTransaction(user3, tid3)
    Bitcoin.addTransaction(btc, tid3)

    block2 = Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user3), difficulty)

    {:ok, tid4} = Transaction.start_link(Owner.getPublicKey(user4), Owner.getPublicKey(user2), 50.00)
    Owner.signTransaction(user4, tid4)
    Bitcoin.addTransaction(btc, tid4)

    {:ok, tid5} = Transaction.start_link(Owner.getPublicKey(user3), Owner.getPublicKey(user1), 50.00)
    Owner.signTransaction(user3, tid5)
    Bitcoin.addTransaction(btc, tid5)

    block3 = Bitcoin.minePendingTransactions(btc, Owner.getPublicKey(user3), difficulty)

    IO.inspect "Is chain valid? -> "
    IO.puts assert Bitcoin.isChainValid(btc) == true

    IO.puts assert Bitcoin.getwalletBalance(btc, user1) == 150.00 + 50.00 + 100.00 +50.00 #mining reward
    IO.puts assert Bitcoin.getwalletBalance(btc, user2) == 200.00 - 50.00 + 50.00 + 50.00
    IO.puts assert Bitcoin.getwalletBalance(btc, user3) == 250.00 + 50.00 - 50.00 - 50.00 + 100.00 #mining reward
    IO.puts assert Bitcoin.getwalletBalance(btc, user4) == 300.00 - 50.00 - 50.00 + 100.00  #mining reward
  end


  # test "greets the world" do
  #   assert Bitcoin.hello() == :world
  # end








end
