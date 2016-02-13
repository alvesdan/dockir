# Dockir

I am using this project to study Elixir.

## How it works?

The application has an Agent running and mantaining the state of the Todo list. The `start_link` method loads the list from a file and on every change of state it persists the changes to the file again.

```elixir
alias Dockir.Todo

# List
Todo.list
[%Todo{id: ..., task: "Just an example", done: false}]

# Add
Todo.add "Pick up keys"
Todo.add "Another task not important"
Todo.add "This one is important"

# Toggle
Todo.toggle {:task, ~r/not important/}

# When the search finds more than one Todo:
Todo.toggle {:task, ~r/important/} == {:error, "Multiple todos matching the given criteria"}

# Search for multiple
Todo.search {:task, ~r/important/}, allow_multiple: true
[%Todo{task: "Another task not important"}, %Todo{task: "This one is important"}]

# Deleting
Todo.delete {:task, ~r/not important/}

# Clear
Todo.clear
```
