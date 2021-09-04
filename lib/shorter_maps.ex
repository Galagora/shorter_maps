defmodule ShorterMaps do
  @readme Path.join(__DIR__, "../README.md")
  @external_resource @readme
  {:ok, readme_contents} = File.read(@readme)
  @moduledoc "#{readme_contents}"

  import ShorterMaps.Utilities

  @default_modifier_m ?s
  @default_modifier_M ?a

  @doc """
  Expands to a string keyed map where the keys are a string containing the
  variable names, e.g. `~m{name}` expands to `%{"name" => name}`.

  Some common uses of `~m` are when working with JSON and Regex captures, which
  use exclusively string keys in their maps.

      # JSON example:
      # Here, `~m{name, age}` expands to `%{"name" => name, "age" => age}`
      iex> ~m{name, age} = Poison.decode!("{\"name\": \"Chris\",\"age\": \"old\"}")
      %{"name" => "Chris", "age" => "old"}
      ...> name
      "Chris"
      ...> age
      "old"


  See the README for extended syntax and usage.
  """
  defmacro sigil_m(term, modifiers)

  defmacro sigil_m({:<<>>, [line: line], [string]}, modifiers) do
    do_sigil_m(string, line, modifier(modifiers, @default_modifier_m))
  end

  defmacro sigil_m({:<<>>, _, _}, _modifiers) do
    raise ArgumentError, "interpolation is not supported with the ~m sigil"
  end

  @doc ~S"""
  Expands an atom-keyed map with the given keys bound to variables with the same
  name.

  Because `~M` operates on atoms, it is compatible with Structs.

  ## Examples:

      # Map construction:
      iex> tty = "/dev/ttyUSB0"
      ...> baud = 19200
      ...> device = ~M{tty, baud}
      %{baud: 19200, tty: "/dev/ttyUSB0"}

      # Map Update:
      ...> baud = 115200
      ...> %{device|baud}
      %{baud: 115200, tty: "/dev/ttyUSB0"}

      # Struct Construction
      iex> id = 100
      ...> ~M{%Person id}
      %Person{id: 100, other_key: :default_val}

  """
  defmacro sigil_M(term, modifiers)
  defmacro sigil_M({:<<>>, [line: line], [string]}, modifiers) do
    do_sigil_m(string, line, modifier(modifiers, @default_modifier_M))
  end
  defmacro sigil_M({:<<>>, _, _}, _modifiers) do
    raise ArgumentError, "interpolation is not supported with the ~M sigil"
  end

  @doc false
  defp do_sigil_m("%" <> _rest, _line, ?s) do
    raise(ArgumentError, "structs can only consist of atom keys")
  end
  defp do_sigil_m(raw_string, line, modifier) do
    with {:ok, struct_name, rest} <- get_struct(raw_string),
         {:ok, old_map, rest} <- get_old_map(rest),
         {:ok, keys_and_values} <- expand_variables(rest, modifier) do
      final_string = "%#{struct_name}{#{old_map}#{keys_and_values}}"
      #IO.puts("#{raw_string} => #{final_string}") # For debugging expansions gone wrong.
      Code.string_to_quoted!(final_string, file: __ENV__.file, line: line)
    else
      {:error, step, reason} ->
        raise(ArgumentError, "ShorterMaps parse error in step: #{step}, reason: #{reason}")
    end
  end
end
