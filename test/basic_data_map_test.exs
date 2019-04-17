defmodule BasicDataMapTest do
  use ExUnit.Case, async: true
  alias Ouidata.BasicDataMap

  test "loads the vendors" do
    {:ok, map} = BasicDataMap.from_file_in_dir("test/ouidata_fixtures")
    result = map[:vendors]
    assert hd(result).comment == "Officially Xerox, but 0:0:0:0:0:0 is more common"
  end
end
