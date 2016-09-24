defmodule ElxChat.TCP.Supervisor do
  use Supervisor
  alias ElxChat.TCP.SocketHandler
  require Logger
  
  @opts [:binary, packet: :line, active: false, reuseaddr: true, exit_on_close: true]

  def start_link() do
    GenServer.start_link(__MODULE__, 4000, name: :tcp_supervisor)
  end

  def init(port) do
    {:ok, socket} = :gen_tcp.listen(port, @opts)

    Logger.info "Listening to #{port} !!!"
    Task.start_link(fn -> listen_for_conn(socket) end)

    children = [
      worker(SocketHandler, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end

  def listen_for_conn(socket) do
    {:ok, conn} = :gen_tcp.accept(socket)

    Logger.info "Got a new connection !!!"
    Supervisor.start_child(:tcp_supervisor, [])

    listen_for_conn(socket)
  end 
end
