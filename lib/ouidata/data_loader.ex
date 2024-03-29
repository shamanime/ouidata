defmodule Ouidata.DataLoader do
  @moduledoc false

  require Logger
  @compile :nowarn_deprecated_function
  # Can poll for newest version of OUI data
  # and can download it.
  @download_url "https://code.wireshark.org/review/gitweb?p=wireshark.git;a=blob_plain;f=manuf"
  def download_new(url \\ @download_url) do
    Logger.debug("Ouidata downloading new data from #{url}")
    set_latest_remote_poll_date()
    {:ok, 200, headers, client_ref} = :hackney.get(url, [], "", follow_redirect: true)
    {:ok, body} = :hackney.body(client_ref)
    content_length = byte_size(body)

    new_dir_name =
      "#{data_dir()}/tmp_downloads/#{content_length}_#{:random.uniform(100_000_000)}/"

    File.mkdir_p!(new_dir_name)
    target_filename = "#{new_dir_name}latest.txt"
    File.write!(target_filename, body)
    release_version = build_release_version()
    Logger.debug("Ouidata data downloaded. Release version #{release_version}.")
    {:ok, content_length, release_version, new_dir_name}
  end

  def build_release_version do
    {y, m, d} = current_date_utc()
    y = to_string(y)
    m = to_string(m) |> String.pad_leading(2, "0")
    d = to_string(d) |> String.pad_leading(2, "0")

    y <> m <> d
  end

  def latest_file_size(url \\ @download_url) do
    set_latest_remote_poll_date()

    case latest_file_size_by_head(url) do
      {:ok, size} ->
        {:ok, size}

      _ ->
        Logger.debug("Could not get latest OUI file size by HEAD request. Trying GET request.")
        latest_file_size_by_get(url)
    end
  end

  defp latest_file_size_by_get(url) do
    case :hackney.get(url, [], "", []) do
      {:ok, 200, _headers, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        {:ok, byte_size(body)}

      {:ok, _status, _headers, client_ref} ->
        :hackney.skip_body(client_ref)
        {:error, :did_not_get_ok_response}

      _ ->
        {:error, :did_not_get_ok_response}
    end
  end

  defp latest_file_size_by_head(url) do
    :hackney.head(url, [], "", [])
    |> do_latest_file_size_by_head
  end

  defp do_latest_file_size_by_head({:error, error}), do: {:error, error}

  defp do_latest_file_size_by_head({_tag, resp_code, _headers}) when resp_code != 200,
    do: {:error, :did_not_get_ok_response}

  defp do_latest_file_size_by_head({_tag, _resp_code, headers}) do
    headers
    |> content_length_from_headers
  end

  defp content_length_from_headers(headers) do
    case value_from_headers(headers, "Content-Length") do
      {:ok, content_length} -> {:ok, content_length |> String.to_integer()}
      {:error, reason} -> {:error, reason}
    end
  end

  defp value_from_headers(headers, key) do
    header =
      headers
      |> Enum.filter(fn {k, _v} -> k == key end)
      |> List.first()

    case header do
      nil -> {:error, :not_found}
      {_, value} -> {:ok, value}
      _ -> {:error, :unexpected_headers}
    end
  end

  def set_latest_remote_poll_date do
    {y, m, d} = current_date_utc()
    File.write!(remote_poll_file_name(), "#{y}-#{m}-#{d}")
  end

  def latest_remote_poll_date do
    latest_remote_poll_file_exists?() |> do_latest_remote_poll_date
  end

  defp do_latest_remote_poll_date(_file_exists = true) do
    File.stream!(remote_poll_file_name())
    |> Enum.to_list()
    |> return_value_for_file_list
  end

  defp do_latest_remote_poll_date(_file_exists = false), do: {:unknown, nil}

  defp return_value_for_file_list([]), do: {:unknown, nil}

  defp return_value_for_file_list([one_line]) do
    date =
      one_line
      |> String.split("-")
      |> Enum.map(&(Integer.parse(&1) |> elem(0)))
      |> List.to_tuple()

    {:ok, date}
  end

  defp return_value_for_file_list(_) do
    raise "latest_remote_poll.txt contains more than 1 line. It should contain exactly 1 line. Remove the file latest_remote_poll.txt in order to resolve the problem."
  end

  defp latest_remote_poll_file_exists?, do: File.exists?(remote_poll_file_name())

  defp current_date_utc, do: :calendar.universal_time() |> elem(0)

  def days_since_last_remote_poll do
    {tag, date} = latest_remote_poll_date()

    case tag do
      :ok ->
        days_today = :calendar.date_to_gregorian_days(current_date_utc())
        days_latest = :calendar.date_to_gregorian_days(date)
        {:ok, days_today - days_latest}

      _ ->
        {tag, date}
    end
  end

  def remote_poll_file_name do
    data_dir() <> "/latest_remote_poll.txt"
  end

  defp data_dir, do: Ouidata.Util.data_dir()
end
