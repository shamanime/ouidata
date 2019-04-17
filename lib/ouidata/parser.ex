defmodule Ouidata.Parser do
  @moduledoc false

  import Ouidata.Util

  def read_file(file_name, dir_prepend) do
    File.stream!("#{dir_prepend}/#{file_name}")
    |> process_file
  end

  def process_file(file_stream) do
    file_stream
    |> filter_comment_lines
    |> filter_empty_lines
    |> Stream.map(fn string -> strip_comment(string) end)
    |> Stream.map(fn string -> String.split(string, "\t") end)
    |> Stream.map(fn x ->
      case x |> Enum.count() do
        3 ->
          %{
            id: x |> Enum.at(0),
            vendor: x |> Enum.at(1),
            comment: x |> Enum.at(2) |> String.trim()
          }

        _ ->
          %{id: x |> Enum.at(0), vendor: x |> Enum.at(1), comment: nil}
      end
    end)
    |> Enum.to_list()
  end
end
