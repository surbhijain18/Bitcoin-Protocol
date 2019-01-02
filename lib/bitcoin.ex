defmodule Bitcoin do
  use GenServer


  def start_link() do
    GenServer.start_link(__MODULE__, [])
  end

  def init([]) do
    #chain, difficulty, pending transactions, miningreward
    {:ok, {[] ++ [createGenesis()], 1, [], 100.00}}
  end

  def createGenesis() do
    {:ok, bid} = Block.start_link(:erlang.system_time(:millisecond))
    Block.setPreviousHash(bid, "") #since a genesis block is the first block of the chain
    Block.setTransaction(bid,[])
    str = Block.getPreviousHash(bid) <> Integer.to_string(Block.getTimeStamp(bid))<> List.to_string(Block.getTransaction(bid)) <> Integer.to_string(0)
    hash = :crypto.hash(:sha256, str) |> Base.encode16
    Block.addHashtoBlock(bid, hash)
    bid
  end

  def minePendingTransactions(bid, miningrewardAddr, difficulty) do
    {:ok, newTrn} = Transaction.start_link("", miningrewardAddr, getMiningReward(bid))
    {:ok, newBlock} = Block.start_link(:erlang.system_time(:millisecond))
    Block.setTransaction(newBlock, getPendingTrns(bid))
    latestBlockHash = Block.getHash(getLastBlock(bid))
    Block.setPreviousHash(newBlock, latestBlockHash)
    Block.updateHash(newBlock, difficulty)
    Block.mineBlock(newBlock, difficulty)
    # IO.puts "Block Successfuly mined"
    addBlock(bid,newBlock)
    setPendingTransactions(bid, [])
    addTransaction(bid, newTrn)
    # Block.printBlockDetails(newBlock)
    newBlock
  end

  def getwalletBalance(bid, oid) do
    blockChain = getChain(bid)
    addr = Owner.getPublicKey(oid)
    initialamt = Owner.getAmount(oid)
    balance = Enum.reduce(blockChain,initialamt, fn(blk, acc)-> acc + getBlockBalance(blk, addr) end)
    # IO.puts "Wallet Balance is BTC#{balance}"
    # sum_list(chain, 0)
    balance

  end

  def getBlockBalance(bid, key) do

    trns = Block.getTransaction(bid)
    bal = Enum.reduce(trns, 0.0, fn(tid, acc) ->
      # IO.puts "Owner initial #{Owner.getAmount(key)}"

      from_address = Transaction.getFromAddress(tid)
      to_address = Transaction.getToAddress(tid)
      cond do
        from_address == key ->
          acc - Transaction.getAmount(tid)
        to_address == key ->
          acc + Transaction.getAmount(tid)
        true ->
          acc
      end
    end)
    bal

  end

  def getMiningReward(bid) do
    GenServer.call( bid,{:returnMR})
  end

  def getPendingTrns(bid) do
    GenServer.call( bid,{:getPending})
  end

  def getLastBlock(bid) do
    GenServer.call( bid,{:latestBlock})
  end

  def getChain(bid) do
    GenServer.call( bid,{:blkchain})
  end

  def addBlock(bid, newBlock) do
    GenServer.cast( bid,{:addblock, newBlock})
  end

  def addTransaction(bid, trn) do
      GenServer.cast( bid,{:addtrn, trn})
  end

  def getGenesisHash(bid) do
    GenServer.call( bid,{:returnGen})
  end

  def setPendingTransactions(bid, transact) do
    GenServer.cast( bid,{:updatepending, transact})
  end

  def handle_call({:returnMR}, _from, state) do
    {_,_,_,rwd} = state
    {:reply, rwd, state}
  end

  def handle_call({:blkchain}, _from, state) do
    {chain,_,_,_} = state
    {:reply, chain, state}
  end

  def handle_call({:getPending}, _from, state) do
    {_,_,trns,_} = state
    {:reply, trns, state}
  end

  def handle_call({:latestBlock}, _from, state) do
    {chain, _, _, _} = state
    {:reply, List.last(chain), state}
  end

  def handle_call({:returnGen}, _from, state) do
    {chain,_,_,_} = state
    {:reply, List.first(chain), state}
  end

  def handle_cast({:addtrn, trn}, state) do
    {chain, diff, transact ,rwd } = state
    state = {chain, diff, transact ++ [trn], rwd}
    {:noreply, state}
  end

  def handle_cast({:updatepending, transacts}, state) do
    {chain, diff, _ ,rwd} = state
    state = {chain, diff, transacts, rwd}
    {:noreply, state}
  end

  def handle_cast({:addblock, newblock}, state) do
    {chain, diff, transact ,rwd} = state
    state = {chain ++ [newblock], diff, transact, rwd}
    {:noreply, state}
  end


  def isGenesisValid(process) do

    #checking if our genesis block is safe and not tampered with
    {:ok, bid} = Block.start_link(:erlang.system_time(:millisecond))
    Block.setPreviousHash(bid, "") #since a genesis block is the first block of the chain
    Block.setTransaction(bid,[])
    str = Block.getPreviousHash(bid) <> Integer.to_string(Block.getTimeStamp(bid)) <> List.to_string(Block.getTransaction(bid)) <> Integer.to_string(0)
    hash = :crypto.hash(:sha256, str) |> Base.encode16
    genBlock = getGenesisHash(process)
    genHash = Block.getHash(genBlock)

    valid = if genHash == hash do
                true
            else
                false
            end
    !valid
    end


    def isChainValid(pid) do
      #only if genesis is valid will our chain be valid, hence checking for genesis
      var = isGenesisValid(pid)
      IO.puts "var #{var}"
      blockChain = getChain(pid)
        iterate = Enum.to_list(1..Enum.count(blockChain)-1)
        verify = Enum.reduce(iterate, true, fn(iterate, acc) ->
          currentBlock = Enum.at(blockChain, iterate)
          previousBlock= Enum.at(blockChain, iterate-1)
          answer1 = Block.getPreviousHash(currentBlock) == Block.getHash(previousBlock)
          # IO.puts "answer1-> #{answer1} acc-> #{acc} BlockValid-> #{Block.isBlockValid(currentBlock)}"
          # answer2 =Block.getHash(currentBlock) == Block.updateHash(currentBlock)
          Block.isBlockValid(currentBlock) and answer1  and acc
        end)
        verify
      end

  def hello do
    :world
  end
end
