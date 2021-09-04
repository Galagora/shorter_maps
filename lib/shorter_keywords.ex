defmodule ShorterKeywords do
  @readme Path.join(__DIR__, "../README.md")
  @external_resource @readme
  {:ok, readme_contents} = File.read(@readme)
  @moduledoc "#{readme_contents}"

  import ShorterMaps.Utilities

  @default_modifier_K ?a

  @doc """
  Expands a list of bindings (variables in the current scope) into a keyword
  list using the variable names as atom keywords.

  ## Examples:

        # KWL construction:
        iex> foo=1
        ...> bar=2
        ...> kwl = ~K{foo, bar}
        [{:foo, 1}, {:bar, 2}]

  """
  defmacro sigil_K(term, modifiers)
  defmacro sigil_K({:<<>>, [line: line], [string]}, modifiers) do
    do_sigil_k(string, line, modifier(modifiers, @default_modifier_K))
  end
  defmacro sigil_K({:<<>>, _, _}, _modifiers) do
    raise ArgumentError, "interpolation is not supported with the ~K sigil"
  end

  @doc false
  defp do_sigil_k(raw_string, line, modifier)

  defp do_sigil_k("%" <> _rest, _line, ?s), do: raise(ArgumentError, "keyword lists can only consist of atom keys")

  defp do_sigil_k(raw_string, line, modifier) do
    IO.puts("raw_string: #{raw_string}, line: #{line}, modifier: #{modifier}") # Debug
    {:ok, keys_and_values} =  expand_variables(raw_string, modifier)
    final_string = "[#{keys_and_values}]"
    IO.puts("#{raw_string} => #{final_string}") # Debug
    Code.string_to_quoted!(final_string, file: __ENV__.file, line: line)
  end
end
