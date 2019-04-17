defmodule Ouidata.BasicDataMap do
  @moduledoc false

  alias Ouidata.Parser

  def from_file_in_dir(dir_name) do
    make_map(Parser.read_file("latest.txt", dir_name))
  end

  def make_map(vendors) do
    {:ok, %{vendors: vendors}}
  end
end
