defmodule Dockir.TodoTest do
  use ExUnit.Case, async: false
  doctest Dockir.Todo
  alias Dockir.Todo

  setup do
    Dockir.Todo.clear
    :ok
  end

  test "it lists existing todos" do
    content = """
CA69F35988AD1EE27921392C6D0F630C    Buy bread    false
0594322A7159D3314CEC4E421E84F511    Call doctor    true
    """

    File.write!(Dockir.File.path, content)

    assert Todo.list(:file) == [
      %Todo{id: "CA69F35988AD1EE27921392C6D0F630C", task: "Buy bread", done: false},
      %Todo{id: "0594322A7159D3314CEC4E421E84F511", task: "Call doctor", done: true}
    ]
  end

  test "it adds new todos" do
    Todo.add("Pick up keys")
    assert "Pick up keys" == Todo.list |> List.last |> Map.fetch!(:task)
  end

  test "it persists changes to file" do
    Todo.add("Send letter")

    assert "Send letter" == Todo.list(:file) |> List.last |> Map.fetch!(:task)
  end

  test "it deletes todos" do
    Todo.add "Call the doctor"
    Todo.add "Pick up keys"
    Todo.delete {:task, ~r/keys/}

    assert Todo.list |> Enum.count == 1
  end

  test "it returns error with multiple matches" do
    Todo.add "Call the doctor"
    Todo.add "Call the company"

    assert Todo.delete({:task, ~r/call/i}) == {:error, "Multiple todos matching the given criteria"}
  end

  test "it completes the task" do
    Todo.add "Call the doctor"
    Todo.add "Pick up keys"

    Todo.toggle {:task, ~r/keys/}

    {:ok, todo} = Todo.search({:task, ~r/keys/})
    assert todo.done == true
  end

  test "it search for multiple todos" do
    Todo.add "Call the doctor"
    Todo.add "Call the company"

    assert Todo.search({:task, ~r/call/i}, allow_multiple: true) |> Enum.count == 2
  end
end
