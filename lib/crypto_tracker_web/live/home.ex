defmodule CryptoTrackerWeb.Home do
  alias CryptoTracker.Coins.Coins
  use CryptoTrackerWeb, :live_view

  def mount(_params, _session, socket) do
    coins =
      Coins.all_coins()

    IO.inspect(coins)
    IO.inspect(coins)
    socket = socket |> stream(:coins, coins)
    {:ok, socket}
  end

  def handle_event("search_crypto", %{"crypto_name" => crypto_name}, socket) do
    socket =
      case Coins.add(crypto_name) do
        {:ok, coin} ->
          socket
          |> put_flash(:info, "Coin added")
          |> stream_insert(:coins, coin)

        {:error, _msg} ->
          socket |> put_flash(:error, "Coin not found")
      end

    {:noreply, socket}
  end
end
