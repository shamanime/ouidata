defmodule Ouidata.EtsHolder do
  @moduledoc false

  require Logger
  use GenServer
  alias Ouidata.DataBuilder
  alias Ouidata.Util

  @file_version 1

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    make_sure_a_release_is_on_file()
    create_current_release_ets_table()
    {:ok, release_name} = load_release()
    {:ok, release_name}
  end

  def new_release_has_been_downloaded do
    GenServer.cast(__MODULE__, :new_release_has_been_downloaded)
  end

  def handle_cast(:new_release_has_been_downloaded, state) do
    {:ok, new_release_name} = load_release()

    if state != new_release_name do
      Logger.info("Ouidata has updated the release from #{state} to #{new_release_name}")
      delete_ets_table_for_version(state)
      delete_ets_file_for_version(state)
    end

    {:noreply, new_release_name}
  end

  defp delete_ets_table_for_version(release_version) do
    Logger.debug("Ouidata deleting ETS table for version #{release_version}")

    release_version
    |> DataBuilder.ets_table_name_for_release_version()
    |> :ets.delete()
  end

  defp delete_ets_file_for_version(release_version) do
    Logger.debug("Ouidata deleting ETS file for version #{release_version}")

    release_version
    |> DataBuilder.ets_file_name_for_release_version()
    |> File.rm()
  end

  defp load_release do
    release_name = newest_release_on_file()
    load_ets_table(release_name)
    set_current_release(release_name)
    {:ok, release_name}
  end

  defp load_ets_table(release_name) do
    file_name = "#{release_dir()}/#{release_name}.v#{@file_version}.ets"
    {:ok, _table} = :ets.file2tab(:erlang.binary_to_list(file_name))
  end

  defp create_current_release_ets_table do
    table = :ets.new(:ouidata_current_release, [:set, :named_table])
    {:ok, table}
  end

  defp set_current_release(release_version) do
    Logger.debug("Ouidata setting current release version to #{release_version}")
    :ets.insert(:ouidata_current_release, {:release_version, release_version})
  end

  defp make_sure_a_release_is_on_file do
    make_sure_a_release_dir_exists()

    cond do
      release_files() == [] and Util.custom_data_dir_configured?() ->
        Logger.info(
          "No ouidata release files found in custom data dir. Copying release file from ouidata priv dir."
        )

        copy_release_dir_from_priv()

      release_files() == [] and not Util.custom_data_dir_configured?() ->
        Logger.error("No ouidata release files found!")

      true ->
        nil
    end
  end

  defp copy_release_dir_from_priv() do
    custom_destination_dir = Ouidata.Util.data_dir() <> "/release_ets"
    priv_release_ets_dir = Application.app_dir(:ouidata, "priv") <> "/release_ets"

    priv_release_ets_dir
    |> release_files_for_dir
    |> Enum.each(fn file ->
      File.copy!(priv_release_ets_dir <> "/" <> file, custom_destination_dir <> "/" <> file)
    end)
  end

  defp make_sure_a_release_dir_exists do
    File.mkdir_p(release_dir())
  end

  defp newest_release_on_file do
    release_files()
    |> List.last()
    |> String.replace(".v#{@file_version}.ets", "")
  end

  defp release_files do
    release_dir()
    |> release_files_for_dir()
  end

  defp release_files_for_dir(dir) do
    dir
    |> File.ls!()
    |> Enum.filter(&Regex.match?(~r/^2\d{7}\.v#{@file_version}\.ets/, &1))
    |> Enum.sort()
  end

  defp release_dir do
    Ouidata.Util.data_dir() <> "/release_ets"
  end

  @doc """
  Returns the file version number used by the current version of Ouidata for the ETS files.
  """
  @spec file_version() :: non_neg_integer()
  def file_version do
    @file_version
  end
end
