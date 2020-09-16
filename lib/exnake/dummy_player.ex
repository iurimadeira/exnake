defmodule Exnake.DummyClient do
  @moduledoc false
  require Logger
  alias Phoenix.Channels.GenSocketClient
  @behaviour GenSocketClient

  def spawn_bot(quantity \\ 1) do
    Enum.map(1..quantity, fn _ -> start_link() end)
  end

  def start_link() do
    GenSocketClient.start_link(
      __MODULE__,
      Phoenix.Channels.GenSocketClient.Transport.WebSocketClient,
      "ws://localhost:12345/socket/websocket"
    )
  end

  def init(url) do
    token = Phoenix.Token.sign(Exnake.Endpoint, "token", UUID.uuid4())
    {:connect, url, [token: token], %{first_join: true, ping_ref: 1}}
  end

  def handle_connected(transport, state) do
    name = "BOT #{UUID.uuid4()}"
    Logger.debug("connected", name: name)
    GenSocketClient.join(transport, "game:play", %{"name" => name})
    {:ok, Map.merge(state, %{name: name})}
  end

  def handle_disconnected(reason, state) do
    Logger.debug("disconnected: #{inspect(reason)}", name: state.name)
    Process.send_after(self(), :connect, :timer.seconds(1))
    {:ok, state}
  end

  def handle_joined(topic, _payload, transport, state) do
    Logger.debug("joined the topic #{topic}", name: state.name)

    GenSocketClient.push(transport, "game:play", "change_direction", %{direction: "up"})

    if state.first_join do
      :timer.send_interval(:timer.seconds(1), self(), :ping_server)
      {:ok, %{state | first_join: false, ping_ref: 1}}
    else
      {:ok, %{state | ping_ref: 1}}
    end
  end

  def handle_join_error(topic, payload, _transport, state) do
    Logger.debug("join error on the topic #{topic}: #{inspect(payload)}", name: state.name)
    {:ok, state}
  end

  def handle_channel_closed(topic, payload, _transport, state) do
    Logger.debug("disconnected from the topic #{topic}: #{inspect(payload)}", name: state.name)
    Process.send_after(self(), {:join, topic}, :timer.seconds(1))
    {:ok, state}
  end

  def handle_message(topic, event, payload, _transport, state) do
    {:ok, state}
  end

  def handle_reply("ping", _ref, %{"status" => "ok"} = payload, _transport, state) do
    {:ok, state}
  end

  def handle_reply(topic, _ref, payload, _transport, state) do
    {:ok, state}
  end

  def handle_info(:connect, _transport, state) do
    Logger.debug("connecting", name: state.name)
    {:connect, state}
  end

  def handle_info({:join, topic}, transport, state) do
    Logger.debug("joining the topic #{topic}", name: state.name)

    case GenSocketClient.join(transport, topic) do
      {:error, reason} ->
        Logger.error("error joining the topic #{topic}: #{inspect(reason)}", name: state.name)
        Process.send_after(self(), {:join, topic}, :timer.seconds(1))

      {:ok, _ref} ->
        :ok
    end

    {:ok, state}
  end

  def handle_info(:ping_server, transport, state) do
    GenSocketClient.push(transport, "ping", "ping", %{ping_ref: state.ping_ref})
    {:ok, %{state | ping_ref: state.ping_ref + 1}}
  end

  def handle_info(message, _transport, state) do
    {:ok, state}
  end
end
