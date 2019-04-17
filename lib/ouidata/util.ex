defmodule Ouidata.Util do
  @moduledoc false

  def strip_comment(line), do: Regex.replace(~r/[\s]*#.+/, line, "")

  def filter_comment_lines(input) do
    Stream.filter(input, fn x -> !Regex.match?(~r/^[\s]*#/, x) end)
  end

  def filter_empty_lines(input) do
    Stream.filter(input, fn x -> !Regex.match?(~r/^\n$/, x) end)
  end

  def data_dir do
    case Application.fetch_env(:ouidata, :data_dir) do
      {:ok, nil} -> Application.app_dir(:ouidata, "priv")
      {:ok, dir} -> dir
      _ -> Application.app_dir(:ouidata, "priv")
    end
  end

  def custom_data_dir_configured? do
    case Application.fetch_env(:ouidata, :data_dir) do
      {:ok, nil} -> false
      {:ok, _dir} -> true
      _ -> false
    end
  end
end
