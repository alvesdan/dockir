defmodule Dockir.Parser do
  @separator "    "

  def parse(content) do
    String.split(content, "\n", trim: true)
    |> Enum.map(fn(line) -> parse_line(line) end)
  end

  defp parse_line(line) do
    Regex.split(~r/\s{3,}/, line)
  end

  def compose(todos) do
    todos
    |> Enum.map(fn(todo) -> compose_line(todo) end) |> Enum.join("\n")
  end

  defp compose_line(todo) do
    [todo.id, todo.task, Atom.to_string(todo.done)]
    |> Enum.join(@separator)
  end
end
