defmodule ShorterKeywordsSpec do
  use ESpec
  import ShorterKeywords

  def eval(quoted_code), do: fn -> Code.eval_quoted(quoted_code) end

  describe "kwl construction" do
    context "~K" do
      example "with one key" do
        key = "value"
        kwl = ~K{key}
        expect kwl |> to(eq(key: "value"))
      end
      example "with several keys" do
        foo = "foo"
        bar = "bar"
        baz = "baz"
        kwl = ~K{foo, bar, baz}
        expect kwl |> to(eq(foo: "foo", bar: "bar", baz: "baz"))
      end
    end
  end
end
