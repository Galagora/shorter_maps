defmodule ShorterMaps.Utilities do
  @moduledoc """
  Utility functions internal to shorter maps.
  """

  @doc false
  # expecting something like: '%StructName key1, key2' -or- '%StructName oldmap|key1, key2'
  # returns {:ok, old_map, keys_and_vars} | {:ok, "", keys_and_vars}
  def get_struct("%" <> rest) do
    [struct_name|others] = String.split(rest, " ")
    body = Enum.join(others, " ")
    {:ok, struct_name, body}
  end
  def get_struct(no_struct), do: {:ok, "", no_struct}

  @re_prefix "[_^]"
  @re_varname ~S"[a-zA-Z0-9_]\w*[?!]?" # use ~S to get a real \
  @doc false
  # expecting something like "old_map|key1, key2" -or- "key1, key2"
  # returns {:ok, "#{old_map}|", keys_and_vars} | {:ok, "", keys_and_vars}
  def get_old_map(string) do
    cond do
      string =~ ~r/\A\s*#{@re_varname}\s*\|/ -> # make sure this is a map update pipe
        [old_map|rest] = String.split(string, "|")
        new_body = Enum.join(rest, "|") # put back together unintentionally split things
        {:ok, "#{old_map}|", new_body}
      true ->
        {:ok, "", string}
    end
  end

  @doc false
  # This works simply:  split the whole string on commas. check each entry to
  # see if it looks like a variable (with or without prefix) or zero-arity
  # function.  If it is, replace it with the expanded version.  Otherwise, leave
  # it alone. Once all the pieces are processed, glue it back together with
  # commas.
  def expand_variables(string, modifier) do
    result = string
             |> String.split(",")
             |> identify_entries()
             |> Enum.map(fn s ->
               cond do
                 s =~ ~r/\A\s*#{@re_prefix}?#{@re_varname}(\(\s*\))?\s*\Z/ ->
                   s
                   |> String.trim
                   |> expand_variable(modifier)
                 true -> s
               end
             end)
             |> Enum.join(",")
     {:ok, result}
  end

  @doc false
  def identify_entries(candidates, partial \\ "", acc \\ [])
  def identify_entries([], "", acc), do: acc |> Enum.reverse
  def identify_entries([], remainder, _acc) do
    # we failed, use code module to raise a syntax error:
    Code.string_to_quoted!(remainder)
  end
  def identify_entries([h|t], partial, acc) do
    entry = case partial do
      "" -> h
      _ -> partial <> "," <> h
    end
    if check_entry(entry, [:map, :list]) do
      identify_entries(t, "", [entry|acc])
    else
      identify_entries(t, entry, acc)
    end
  end

  @doc false
  def check_entry(_entry, []), do: false
  def check_entry(entry, [:map|rest]) do
    case Code.string_to_quoted("%{#{entry}}") do
      {:ok, _} -> true
      {:error, _} -> check_entry(entry, rest)
    end
  end
  def check_entry(entry, [:list|rest]) do
    case Code.string_to_quoted("[#{entry}]") do
      {:ok, _} -> true
      {:error, _} -> check_entry(entry, rest)
    end
  end


  @doc false
  def expand_variable(var, ?s) do
    "\"#{fix_key(var)}\" => #{var}"
  end
  def expand_variable(var, ?a) do
    "#{fix_key(var)}: #{var}"
  end

  @doc false
  def fix_key("_" <> name), do: name
  def fix_key("^" <> name), do: name
  def fix_key(name) do
    String.replace_suffix(name, "()", "")
  end

  @doc false
  def modifier([], default), do: default
  def modifier([mod], _default) when mod in 'as', do: mod
  def modifier(_, _default) do
    raise(ArgumentError, "only these modifiers are supported: s, a")
  end

end
