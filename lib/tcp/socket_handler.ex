defmodule ElxChat.TCP.SocketHandler do
  use GenServer
  require Logger
  
  def start_link(conn) do
    Logger.info "Inside start_link"
    GenServer.start_link(__MODULE__, conn)
  end

  def init([conn]) do
    case :gen_tcp.recv(conn, 0) do
      {:ok, data} ->
        Logger.info "Got :: #{data}"
        :gen_tcp.send(conn, data)
        init(conn)

      {:error, :closed} -> :ok
    end
  end
end
