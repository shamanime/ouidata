defmodule Ouidata do
  @moduledoc """
  The Ouidata module provides data from the Wireshark OUI database.

  A list of OUIs and vendors is provided.
  As well as functions for finding out specific vendors from OUis.
  """

  @type oui :: %{
          address: String.t(),
          vendor: String.t(),
          comment: String.t()
        }

  @doc """
  vendor_list provides a list of all the known addresses and their
  vendors.
  """
  @spec vendor_list() :: [oui]
  def vendor_list, do: Ouidata.ReleaseReader.vendors()

  @doc """
  Returns ouidata release version as a string.

  Example:

      Ouidata.ouidata_version
      "20190416"
  """
  @spec ouidata_version() :: String.t()
  def ouidata_version, do: Ouidata.ReleaseReader.release_version()

  @doc """
  Gets a matching OUI entry.

  Returns nil if not found.

  ## Example

      Ouidata.get("00:00:69:AB:AB:AB")
      %{comment: "Concord Communications Inc", id: "00:00:69", vendor: "ConcordC"}
  """
  def get(address) do
    Ouidata.ReleaseReader.get(address)
  end

  @doc """
  Gets a MAC address vendor.

  Returns nil if not found.

  ## Example

      Ouidata.get_vendor("00:00:69:AB:AB:AB")
      "ConcordC"
  """
  def get_vendor(address) do
    Ouidata.ReleaseReader.get_vendor(address)
  end

  @doc """
  Gets a MAC address vendor.

  Returns nil if not found.

  ## Example

      Ouidata.get_comment("00:00:69:AB:AB:AB")
      "Concord Communications Inc"
  """
  def get_comment(address) do
    Ouidata.ReleaseReader.get_comment(address)
  end
end
