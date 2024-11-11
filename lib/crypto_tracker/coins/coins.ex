defmodule CryptoTracker.Coins.Coins do
  alias CryptoTracker.Workers.CoinWorker
  alias CryptoTracker.Coins.CoinService

  def add(coin) do
    case CoinService.fetch_current_price(coin) do
      {:ok, price} ->
        CoinWorker.add_coin(%{id: coin, price: price})
        {:ok, %{id: coin, price: price}}

      {:error, msg} ->
        {:error, msg}
    end
  end

  def all_coins do
    CoinWorker.all_coins()
  end

  def update_price(coin) do
    case CoinService.fetch_current_price(coin.id) do
      {:ok, price} ->
        %{coin | price: price}

      {:error, _msg} ->
        coin
    end
  end
end
