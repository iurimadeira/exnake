defmodule Exnake.Benchmark do
  use GenServer

  require Logger

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    schedule_print()
    {:ok, %{total_quantity: 0, quantity: 0, skip_quantity: 0}}
  end

  def handle_cast({:register_new_tick}, %{quantity: quantity} = state) do
    {:noreply, %{state | quantity: quantity + 1}}
  end

  def handle_cast({:register_skip}, %{skip_quantity: skip_quantity} = state) do
    {:noreply, %{state | skip_quantity: skip_quantity + 1}}
  end

  def handle_info({:print}, %{
        total_quantity: total_quantity,
        quantity: quantity,
        skip_quantity: skip_quantity
      }) do
    new_total_quantity = total_quantity + quantity + skip_quantity

    Logger.info(
      "#{NaiveDateTime.utc_now()} # #{new_total_quantity} runs # #{quantity} GS/s # #{
        skip_quantity
      } skips/s"
    )

    schedule_print()
    {:noreply, %{total_quantity: new_total_quantity, quantity: 0, skip_quantity: 0}}
  end

  defp schedule_print do
    Process.send_after(self(), {:print}, 1000)
  end
end
