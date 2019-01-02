defmodule Owner do
  use GenServer

  def start_link(amt) do
    GenServer.start_link(__MODULE__, amt)
  end

  def init(amt) do
    {publicKey, privateKey} = :crypto.generate_key(:ecdh, :crypto.ec_curve(:secp256k1))
    {:ok, {privateKey, publicKey, amt}}
  end

  def signTransaction(actor, tid) do
    valid = if getPublicKey(actor) != Transaction.getFromAddress(tid) do
              false
    else
      hashTrn = Transaction.getAmount(tid)
      # setAmount(actor, hashTrn)
      # IO.puts "amount $$ #{hashTrn}"
      privateKey = getPrivateKey(actor)
      signature = :crypto.sign(:ecdsa, :sha256, Float.to_string(hashTrn), [privateKey, :secp256k1])
      Transaction.setSign(tid,signature)
      true
    #  IO.puts "signature #{Transaction.getSignature(tid)}"
    end
    valid
  end

  #get methods
  def getPublicKey(actor) do
    GenServer.call(actor, {:getPubKey})
  end

  def getPrivateKey(actor) do
    GenServer.call(actor, {:getPriKey})
  end

  def getAmount(actor) do
    GenServer.call(actor, {:getAmt})
  end

  def setAmount(actor, amt) do
    GenServer.cast(actor,{:setamout, amt})
  end

  def handle_call({:getPubKey}, _from, state) do
    {_, pk,_} = state
    {:reply, pk, state}
  end

  def handle_call({:getAmt}, _from, state) do
    {_, _,amt} = state
    {:reply, amt, state}
  end

  def handle_call({:getPriKey}, _from, state) do
    {pk, _, _} = state
    {:reply, pk, state}
  end

  def handle_cast({:setamout, amt}, state) do
    {prk, puk, _} = state
    state = {prk, puk, amt}
    {:noreply, state}
  end
end
