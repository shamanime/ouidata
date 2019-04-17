defmodule Ouidata.ReleaseUpdater do
  @moduledoc false

  require Logger
  use GenServer
  alias Ouidata.DataLoader

  def start_link() do
    GenServer.start_link(__MODULE__, [], name: :ouidata_release_updater)
  end

  def init([]) do
    Process.send_after(self(), :check_if_time_to_update, 3000)
    {:ok, []}
  end

  @msecs_between_checking_date 18_000_000
  def handle_info(:check_if_time_to_update, state) do
    check_if_time_to_update()
    Process.send_after(self(), :check_if_time_to_update, @msecs_between_checking_date)
    {:noreply, state}
  end

  @days_between_remote_poll 1
  def check_if_time_to_update do
    {tag, days} = DataLoader.days_since_last_remote_poll()

    case tag do
      :ok ->
        if days >= @days_between_remote_poll do
          poll_for_update()
        end

      _ ->
        poll_for_update()
    end
  end

  def poll_for_update do
    Logger.debug("Ouidata polling for update.")

    case loaded_ouidata_matches_newest_one?() do
      {:ok, true} ->
        Logger.debug("Ouidata polling shows the loaded OUI database is up to date.")
        :do_nothing

      {:ok, false} ->
        case Ouidata.DataBuilder.load_and_save_table() do
          {:ok, _, _} ->
            Ouidata.EtsHolder.new_release_has_been_downloaded()

          {:error, error} ->
            {:error, error}
        end

      _ ->
        :do_nothing
    end
  end

  defp loaded_ouidata_matches_newest_one? do
    {tag, filesize} = Ouidata.DataLoader.latest_file_size()

    case tag do
      :ok ->
        {:ok, filesize == Ouidata.ReleaseReader.archive_content_length()}

      _ ->
        {tag, nil}
    end
  end
end
