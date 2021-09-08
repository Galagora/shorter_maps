defmodule UtilsSpec do
  use ESpec

  describe "classify_kwl_string" do
    it "identifies create syntax" do
      result = ShorterMaps.Utilities.classify_kwl_string("foo, bar, baz")
      expect(result) |> to(eq({:create, ["foo", "bar", "baz"]}))
    end
    it "identifies merge syntax" do
      expect(ShorterMaps.Utilities.classify_kwl_string("kwl| foo, bar, baz")) |> to(eq({:merge, "kwl", ["foo", "bar", "baz"]}))
      expect(ShorterMaps.Utilities.classify_kwl_string("kwl | foo, bar, baz")) |> to(eq({:merge, "kwl", ["foo", "bar", "baz"]}))
    end

    it "identifies destructure syntax" do
      expect(ShorterMaps.Utilities.classify_kwl_string("kwl foo, bar, baz")) |> to(eq({:destructure, "kwl", ["foo", "bar", "baz"]}))
      expect(ShorterMaps.Utilities.classify_kwl_string("kwl  foo, bar, baz")) |> to(eq({:destructure, "kwl", ["foo", "bar", "baz"]}))
    end
  end
end
