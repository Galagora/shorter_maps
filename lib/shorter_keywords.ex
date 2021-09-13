defmodule ShorterKeywords do
  @moduledoc """
  ~K{} implementation
  """

  import ShorterMaps.Utilities, only: [classify_kwl_string: 1, expand_kwl_vars: 1]

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
    do_sigil_k(string, line, modifier(modifiers))
  end
  defmacro sigil_K({:<<>>, _, _}, _modifiers), do: raise ArgumentError, "interpolation is not supported with the ~K sigil"

  @doc false
  defp do_sigil_k(raw_string, line, modifier)
  defp do_sigil_k(raw_string, _line, _modifier) do
    # IO.puts("raw_string: #{raw_string}, line: #{line}") # Debug
    case classify_kwl_string(raw_string) do
      {:create, vars} ->
        expansion = expand_kwl_vars(vars)
        code = "[#{expansion}]"
        # IO.puts("code => #{code}")
        Code.string_to_quoted!(code)

      {:merge, kwl, vars} ->
        create = expand_kwl_vars(vars)
        code = "Keyword.merge(#{kwl}, #{create})"
        # IO.puts("code => #{code}")
        Code.string_to_quoted!(code)

      {:destructure, kwl, vars} ->
        code = Enum.reduce(vars, "", fn(var, acc) ->
          "#{acc}#{var} = Keyword.get(#{kwl}, :#{var}); "
        end)
        # IO.puts("code => #{code}")
        Code.string_to_quoted!(code)
    end
  end

  @doc false
  defp modifier([]), do: []
end
