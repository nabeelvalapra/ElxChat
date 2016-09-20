defmodule ElxChat.Registry do
  use GenServer

  ## Client Stuffs.
  
  def start_link do
    GenServer.start_link(__MODULE__, [], name: :chat_registry)
  end

  def all_rooms() do
    GenServer.call(:chat_registry, {:all_rooms})
  end

  def whereis_name(room_name) do 
    GenServer.call(:chat_registry, {:whereis_name, room_name})
  end

  def register_name(room_name, pid) do 
    GenServer.call(:chat_registry, {:register_room, room_name, pid})
  end 

  def unregister_name(room_name) do 
    GenServer.cast(:chat_registry, {:unregister_room, room_name})
  end

  def send(room_name, message) do 
    case whereis_name(room_name) do 
      :undefined -> 
        {:badarg, {room_name, message}}

      pid -> 
        Kernel.send(pid, message)  
        pid
    end
  end 

  ## Server Stuffs

  def init(_) do 
    {:ok, Map.new}
  end 

  def handle_call({:all_rooms}, _from, state) do
    {:reply, Map.keys(state), state}
  end
 
  def handle_call({:whereis_name, room_name}, _from, state) do 
    {:reply, Map.get(state, room_name, :undefined), state}
  end 

  def handle_call({:register_room, room_name, pid}, _from, state) do 
    case Map.get(state, room_name) do 
      nil -> 
        Process.monitor(pid)
        {:reply, :yes, Map.put(state, room_name, pid)}
      _ ->
        {:reply, :no, state} 
    end 
  end 

  def handle_info({:DOWN, _, :process, pid, _}, state) do 
    {:noreply, remove_pid(state, pid)}
  end

  def handle_cast({:unregister_name, room_name}, state) do 
    {:noreply, Map.delete(state, room_name)}
  end 

  def remove_pid(state, pid_to_remove) do
    remove = fn {_key, pid} -> pid  != pid_to_remove end
    Enum.filter(state, remove) |> Enum.into(%{})
  end
end 
