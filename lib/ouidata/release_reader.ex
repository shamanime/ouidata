defmodule Ouidata.ReleaseReader do
  @moduledoc false

  def vendors, do: simple_lookup(:vendors) |> hd |> elem(1)
  def release_version, do: simple_lookup(:release_version) |> hd |> elem(1)
  def archive_content_length, do: simple_lookup(:archive_content_length) |> hd |> elem(1)

  def get(address) do
    do_get(address)
  end

  def get_comment(address) do
    if result = do_get(address) do
      Map.get(result, :comment)
    end
  end

  def get_vendor(address) do
    if result = do_get(address) do
      Map.get(result, :vendor)
    end
  end

  defp do_get(address) do
    vendors()
    |> Enum.find(fn x ->
      x.id == address |> String.upcase() |> String.slice(0..7)
    end)
  end

  defp simple_lookup(key) do
    :ets.lookup(current_release_from_table() |> table_name_for_release_name, key)
  end

  defp current_release_from_table do
    :ets.lookup(:ouidata_current_release, :release_version) |> hd |> elem(1)
  end

  defp table_name_for_release_name(release_name) do
    "ouidata_rel_#{release_name}" |> String.to_atom()
  end
end
