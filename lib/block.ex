defmodule Block do
  use GenServer


  def start_link(time) do
    GenServer.start_link(__MODULE__, time)
  end

  #A block will store the following details:
  #previous hash, time stamp, transactions, hash, nonce
  def init(time) do
    # time = :erlang.system_time(:millisecond)
    {:ok, {"", time, [], calculateHash(time), 0}}
  end


  def printBlockDetails(bid) do
    IO.puts "__________________________________________________________"
    IO.puts "Block Details"

    IO.puts "Previous Block Hash->#{getPreviousHash(bid)}"
    IO.puts "TimeStamp-> #{Integer.to_string(getTimeStamp(bid))}"
    IO.puts "Transaction->"
    IO.inspect getTransaction(bid)

    IO.puts "Hash of Block -> #{getHash(bid)}"
    IO.puts "Nonce->#{getNonce(bid)}"
    IO.puts "__________________________________________________________"

  end

  def calculateHash(time) do
    str = ""
    st = str <> Integer.to_string(time) <>List.to_string([]) <> Integer.to_string(0)
    hash = :crypto.hash(:sha256, st) |> Base.encode16
    # IO.puts hash
    hash
  end


  def mineBlock(bid, difficulty) do
    transactions = Integer.to_string(Kernel.length(getTransaction(bid)))
    hash = generateHash(difficulty, bid, getPreviousHash(bid), getTimeStamp(bid), transactions, getNonce(bid))
    IO.puts "block mined. hash is-> #{hash}"
    addHashtoBlock(bid, hash)
  end


  def generateHash(difficulty, bid, prevhash, timestamp, trns, nonce) do
      str = prevhash <> (Integer.to_string(timestamp)) <> trns <> (Integer.to_string(nonce))
      hash = :crypto.hash(:sha256, str) |> Base.encode16
      rqd = String.duplicate("0", difficulty)
      cond do
        String.slice(hash, 0..difficulty-1) == rqd ->
          setNonce(bid, nonce)
          hash
        true ->
          nonce = nonce + 1
          generateHash(difficulty, bid, prevhash, timestamp, trns, nonce )
      end
  end


  def updateHash(bid, difficulty) do
    transactions = Integer.to_string(Kernel.length(getTransaction(bid)))
    hash = generateHash(difficulty, bid, getPreviousHash(bid), getTimeStamp(bid),transactions,getNonce(bid))
    addHashtoBlock(bid, hash)
  end



   def isBlockValid(bid) do
    transactions = getTransaction(bid)
    valid = Enum.reduce(transactions, true, fn(tid, acc) ->
      cond do
        Transaction.getFromAddress(tid) == "" ->
          true
        true ->
          acc and :crypto.verify(:ecdsa, :sha256, Float.to_string(Transaction.getAmount(tid)), Transaction.getSignature(tid) , [Transaction.getFromAddress(tid),:secp256k1])
      end
    end)
    IO.puts "BlockValid -> #{valid}"
    valid

   end

  #get functions for all attrbutes of Block
  def getPreviousHash(bid) do
    GenServer.call(bid, {:returnPrevHash})
  end

  def getHash(bid) do
    GenServer.call(bid, {:returnHash})
  end

  def getTimeStamp(bid) do
    GenServer.call(bid, {:returnTimeStamp})
  end
  def getTransaction(bid) do
    GenServer.call(bid, {:returnTrns})
  end
  def getNonce(bid) do
    GenServer.call(bid, {:returnNonce})
  end

  def handle_call({:returnPrevHash}, _from, state) do
    {prev, _, _, _, _} = state
    {:reply, prev, state}
  end

  def handle_call({:returnHash}, _from, state) do
    {_, _, _, hash,_} = state
    {:reply, hash, state}
  end

  def handle_call({:returnTimeStamp}, _from, state) do
    {_, time, _, _, _} = state
    {:reply, time, state}
  end

  def handle_call({:returnTrns}, _from, state) do
    {_, _, trns, _, _} = state
    {:reply, trns, state}
  end

  def handle_call({:returnNonce}, _from, state) do
    {_, _, _, _, nonce} = state
    {:reply, nonce, state}
  end

  #set functions for all attributes

  def addHashtoBlock(bid, hash) do
    GenServer.cast(bid, {:add_hash, hash})
  end

  def setNonce(bid, nonce) do
    GenServer.cast(bid, {:set_nonce, nonce})
  end

  def setTransaction(bid, trns) do
    GenServer.cast(bid, {:setTrns, trns})
  end

  def setPreviousHash(bid, prevhash) do
    GenServer.cast(bid, {:setprevhash, prevhash})
  end


  def handle_cast({:add_hash, newhash}, state) do
    {prev, time, trns, _, nonce} = state
    state = {prev, time, trns, newhash, nonce}
    {:noreply, state}
  end

  def handle_cast({:setprevhash, phash}, state) do
    {_, time, trns, hash, nonce} = state
    state = {phash, time, trns, hash, nonce}
    {:noreply, state}
  end

  def handle_cast({:setTrns, trns}, state) do
    {prev, time, _, hash, nonce} = state
    state = {prev, time, trns, hash, nonce}
    {:noreply, state}
  end

  def handle_cast({:set_nonce, nonce}, state) do
    {prev, time, trns, hash ,_} = state
    state = {prev, time, trns, hash, nonce}
    {:noreply, state}
  end


end
