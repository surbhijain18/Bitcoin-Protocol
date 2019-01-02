defmodule Transaction do
  use GenServer

  def start_link(fromAddr, toAddr, amount) do
    GenServer.start_link(__MODULE__, [fromAddr, toAddr, amount])
  end

  def init([fromAddr, toAddr, amount]) do
    {:ok, {fromAddr, toAddr, amount, None}}
  end

  def isTransactionValid(tid) do
    result = if getFromAddress(tid) == "" do
                true
            else
              :crypto.verify(:ecdsa, :sha256, Float.to_string(Transaction.getAmount(tid)), Transaction.getSignature(tid) , [Transaction.getFromAddress(tid),:secp256k1])
            end
    result
  end


  def getFromAddress(tid) do
    GenServer.call(tid, {:fromAddress})
  end

  def getSignature(tid) do
    GenServer.call(tid, {:getSign})
  end

  def getAmount(tid) do
    GenServer.call(tid, {:getAmt})
  end

  def setAmount(tid, amt) do
    GenServer.cast(tid,{:updateamt, amt})
  end

  def getToAddress(pid) do
    GenServer.call(pid, {:toAddress})
  end

  def setSign(tid, sign) do
    GenServer.cast(tid,{:updateSign, sign})
  end

  def handle_call({:fromAddress}, _from, state) do
    {fromAddr, _, _, _ } = state
    {:reply, fromAddr, state}
  end

  def handle_call({:getSign}, _from, state) do
    {_, _, _, sign} = state
    {:reply, sign, state}
  end

  def handle_call({:getAmt}, _from, state) do
    {_, _, amount, _} = state
    {:reply, amount, state}
  end

  def handle_call({:toAddress}, _from, state) do
    {_, to_address, _, _} = state
    {:reply, to_address, state}
  end

  def handle_cast({:updateSign, sign}, state) do
    {from, to, amt, _} = state
    state = {from, to, amt, sign}
    {:noreply, state}
  end


  def handle_cast({:updateamt, amt}, state) do
    {from, to, _, sign} = state
    state = {from, to, amt, sign}
    {:noreply, state}
  end

  def calculateTrnHash(tid) do
    to = getToAddress(tid)
    from = getFromAddress(tid)
    amt = getAmount(tid)
    line = from <> to <> Float.to_string(amt)
    h = :crypto.hash(:sha256, line) |> Base.encode16
    line
  end
end
