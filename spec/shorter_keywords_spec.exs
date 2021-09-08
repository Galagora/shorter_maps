defmodule ShorterKeywordsSpec do
  use ESpec
  import ShorterKeywords

  describe "kwl construction" do
    context "~K" do
      example "with one key" do
        key = "value"
        kwl = ~K{key}
        expect kwl |> to(contain_exactly(key: "value"))
      end
      example "with several keys" do
        foo = "foo"
        bar = "bar"
        baz = "baz"
        kwl = ~K{foo, bar, baz}
        expect kwl |> to(contain_exactly(foo: "foo", bar: "bar", baz: "baz"))
      end
      example "with key assignments" do
        foo = "foo"
        kwl = ~K{foo, bar: "bar"}
        expect kwl |> to(contain_exactly(foo: "foo", bar: "bar"))
      end
    end
  end

  describe "kwl update and merge" do
    context "~K" do
      example "updates a single kwl item" do
        kwl = [foo: "foo", bar: "bar"]
        baz = "baz"
        result = ~K{kwl| baz}
        expect result |> to(contain_exactly(foo: "foo", bar: "bar", baz: "baz"))
      end
      example "updates and adds several kwl items" do
        kwl = [foo: "foo", bar: "bar"]
        baz = "baz"
        foo = "new foo"
        result = ~K{kwl| foo, baz}
        expect result |> to(contain_exactly(foo: "new foo", bar: "bar", baz: "baz"))
      end
      example "with key assignments" do
        kwl = [foo: "foo", bar: "bar"]
        foo = "new foo"
        result = ~K{kwl| foo, baz: "baz"}
        expect result |> to(contain_exactly(foo: "new foo", bar: "bar", baz: "baz"))
      end
    end
  end

  describe "kwl destructuring" do
    context "~K{key, ...} = " do
      example "with one key" do
        kwl = [key: "value"]
        ~K{kwl key}
        expect key |> to(eq("value"))
      end

      example "with several keys" do
        kwl = [foo: "foo", bar: "bar", baz: "baz"]
        ~K{kwl foo}
        ~K{kwl bar, baz}
        expect foo |> to(eq("foo"))
        expect bar |> to(eq("bar"))
        expect baz |> to(eq("baz"))
      end
    end
  end
end
