defmodule Dockir.Todo do
  defstruct id: nil, task: nil, done: false
  alias Dockir.Todo

  def start_link do
    Agent.start_link(fn -> Todo.list(:file) end, name: __MODULE__)
  end

  def list(:file), do: list_from_file

  def list do
    Agent.get(__MODULE__, fn(todos) -> todos end)
  end

  def add(task) do
    Agent.update(__MODULE__, fn(todos) ->
      todos ++ [%Todo{id: generate_id(task), task: task}]
    end)

    save_to_file!
  end

  def delete({key, value}) do
    case search({key, value}) do
      {:ok, todo} ->
        Agent.update(__MODULE__, fn(todos) ->
          Enum.reject(todos, fn(t) -> t.id == todo.id end)
        end)
        save_to_file!
      error -> error
    end
  end

  def toggle({key, value}) do
    case search({key, value}) do
      {:ok, todo} ->
        Agent.update(__MODULE__, fn(todos) ->
          Enum.map(todos, fn(t) ->
            case todo do
              ^t -> %Todo{t | done: !t.done}
              _ -> t
            end
          end)
        end)
        save_to_file!
      error -> error
    end
  end

  def clear do
    Agent.update(__MODULE__, fn(_) -> [] end)
    save_to_file!
  end

  def search({key, regex}) do
    search({key, regex}, allow_multiple: false)
  end

  def search({key, regex}, opts \\ []) do
    todos = Todo.list
    |> Enum.filter(fn(todo) ->
      case Map.fetch(todo, key) do
        {:ok, v} -> Regex.match?(regex, v)
        {:error} -> false
        _ -> false
      end
    end)

    case Enum.count(todos) do
      0 -> {:not_found, "Can't find a todo with given criteria"}
      1 -> {:ok, List.first(todos)}
      _ ->
        if opts[:allow_multiple] do
          todos
        else
          {:error, "Multiple todos matching the given criteria"}
        end
    end
  end

  defp list_from_file do
    case File.read(Dockir.File.path) do
      {:ok, content} ->
        Dockir.Parser.parse(content)
        |> Enum.map(fn(fields) ->
          [id, task, done] = fields
          %Todo{id: id, task: task, done: String.to_atom(done)}
        end)
      {:error, _reason} ->
        File.write!(Dockir.File.path, "")
        []
    end
  end

  defp generate_id(task) do
    time = :os.system_time(:seconds) |> Integer.to_string
    :crypto.hash(:md5, time <> task) |> Base.encode16
  end

  defp save_to_file! do
    Dockir.File.save(Todo.list)
  end
end
