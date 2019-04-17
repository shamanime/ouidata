defmodule OuidataTest do
  use ExUnit.Case
  doctest Ouidata

  describe "vendor_list/0" do
    test "list all vendors" do
      assert Ouidata.vendor_list() |> length() > 0
    end
  end

  describe "ouidata_version/0" do
    test "displays the current file version" do
      assert Ouidata.ouidata_version() == "20190416"
    end
  end

  describe "get/1" do
    test "fetches all information from a vendor" do
      assert Ouidata.get("00:00:69:AB:AB:AB") == %{
               comment: "Concord Communications Inc",
               id: "00:00:69",
               vendor: "ConcordC"
             }
    end

    test "returns nil if vendor is not found" do
      assert Ouidata.get("FF:FF:FF:AB:AB:AB") == nil
    end
  end

  describe "get_vendor/1" do
    test "fetches the vendor name" do
      assert Ouidata.get_vendor("00:00:69:AB:AB:AB") == "ConcordC"
    end

    test "returns nil if vendor is not found" do
      assert Ouidata.get_vendor("FF:FF:FF:AB:AB:AB") == nil
    end
  end

  describe "get_comment/1" do
    test "fetches the vendor comment" do
      assert Ouidata.get_comment("00:00:69:AB:AB:AB") == "Concord Communications Inc"
    end

    test "returns nil if vendor is not found" do
      assert Ouidata.get_comment("FF:FF:FF:AB:AB:AB") == nil
    end
  end
end
