defmodule Ouidata.DataBuilder do
  @moduledoc false
  alias Ouidata.DataLoader
  require Logger

  # download new data releases, then parse them
  # and save the data in an ETS table
  def load_and_save_table do
    {:ok, content_length, release_version, ouidata_dir} = DataLoader.download_new()
    current_version = Ouidata.ReleaseReader.release_version()

    if release_version == current_version do
      # remove temporary ouidata dir
      File.rm_rf(ouidata_dir)

      Logger.info(
        "Downloaded ouidata release from Wireshark is the same file as the file currently in use (#{
          current_version
        })."
      )

      {:error, :downloaded_version_same_as_current_version}
    else
      do_load_and_save_table(content_length, release_version, ouidata_dir)
    end
  end

  defp do_load_and_save_table(content_length, release_version, ouidata_dir) do
    ets_table_name = ets_table_name_for_release_version(release_version)
    table = :ets.new(ets_table_name, [:bag, :named_table])
    {:ok, map} = Ouidata.BasicDataMap.from_file_in_dir(ouidata_dir)
    :ets.insert(table, {:release_version, release_version})
    :ets.insert(table, {:archive_content_length, content_length})
    :ets.insert(table, {:vendors, map.vendors})

    # remove temporary ouidata dir
    File.rm_rf(ouidata_dir)
    ets_tmp_file_name = "#{release_dir()}/#{release_version}.tmp"
    ets_file_name = ets_file_name_for_release_version(release_version)
    File.mkdir_p(release_dir())
    # Create file using a .tmp line ending to avoid it being
    # recognized as a complete file before writing to it is complete.
    :ets.tab2file(table, :erlang.binary_to_list(ets_tmp_file_name))
    :ets.delete(table)
    # Then rename it, which should be an atomic operation.
    :file.rename(ets_tmp_file_name, ets_file_name)
    {:ok, content_length, release_version}
  end

  def ets_file_name_for_release_version(release_version) do
    "#{release_dir()}/#{release_version}.v#{Ouidata.EtsHolder.file_version()}.ets"
  end

  def ets_table_name_for_release_version(release_version) do
    String.to_atom("ouidata_rel_#{release_version}")
  end

  defp release_dir do
    Ouidata.Util.data_dir() <> "/release_ets"
  end
end
