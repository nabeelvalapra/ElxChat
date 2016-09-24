defmodule ElxChat.Server do
  use GenServer
  
  # API

  def start_link(room_name) do 
    GenServer.start_link(__MODULE__, [], name: via_tuple(room_name))
  end

  def add_message(room_name, message) do 
    GenServer.cast(via_tuple(room_name), {:add_message, message}) 
  end

  def get_messages(room_name) do 
    GenServer.call(via_tuple(room_name), :get_messages)
  end   

  # Private Functions
  
  defp via_tuple(room_name) do 
    {:via, ElxChat.Registry, {:chat_room, room_name}}
  end

  # Callback 
  
  def init(messages) do
    {:ok, messages}
  end

  def handle_cast({:add_message, message}, messages) do 
    {:noreply, [message | messages]}
  end 

  def handle_call(:get_messages, _from, messages) do 
    {:reply, messages, messages}
  end 

end
