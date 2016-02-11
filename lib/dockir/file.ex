defmodule Dockir.File do
  def path do
    Application.get_env(:dockir, :file_path)
  end

  def save(todos) do
    File.write!(Dockir.File.path,
      Dockir.Parser.compose(todos), [:write])
  end
end
