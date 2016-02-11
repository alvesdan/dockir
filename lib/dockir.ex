defmodule Dockir do
  def start(_type, _args), do: Dockir.Todo.start_link
end
