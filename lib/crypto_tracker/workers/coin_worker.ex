defmodule CryptoTracker.Workers.CoinWorker do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def add_coin(coin) do
    GenServer.cast(__MODULE__, {:add_coin, coin})
  end

  def all_coins do
    GenServer.call(__MODULE__, :all_coins)
  end

  def init(state) do
    schedule_coin_refresh()
    {:ok, state}
  end

  def handle_cast({:add_coin, coin}, state) do
    {:noreply, [coin | state]}
  end

  def handle_call(:all_coins, _from, state) do
    {:reply, state, state}
  end

  def handle_info(:update_coins, state) do
    {:noreply, state, {:continue, :get_coin_prices}}
  end

  def handle_continue(:get_coin_prices, state) do
    updated_coin_prices = update_coin_prices(state)
    Logger.info("Coins refreshed")
    schedule_coin_refresh()
    {:noreply, updated_coin_prices}
  end

  defp update_coin_prices(state) do
    state
    |> Task.async_stream(&CryptoTracker.Coins.Coins.update_price(&1))
    |> Enum.map(fn {:ok, result} -> result end)
  end

  defp schedule_coin_refresh do
    Logger.info("Scheduling a refresh in 1 min")
    Process.send_after(self(), :update_coins, 60_000)
  end
end
