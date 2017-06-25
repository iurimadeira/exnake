defmodule Exnake.GameChannel do
  use Exnake.Web, :channel

  def join("game:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def handle_in("change_direction", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # TODO Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
