defmodule Bookclub.TypeHelpers do
  @moduledoc """
  Describes functions to help with type matching.
  """

  @integer_regex ~r/(?<=\s|^)\d+(?=\s|$)/

  @doc """
  Expresses if a given binary is equivalent to a integer value.

  ## Examples

  iex> Bookclub.TypeHelpers.is_binary_integer(:test)
  false

  iex> Bookclub.TypeHelpers.is_binary_integer("Hi")
  false

  iex> Bookclub.TypeHelpers.is_binary_integer("55.2")
  false

  iex> Bookclub.TypeHelpers.is_binary_integer("55")
  true
  """
  @spec is_binary_integer(any()) :: boolean()
  def is_binary_integer(binary) when not is_binary(binary) do
    false
  end

  def is_binary_integer(binary) do
    Regex.match?(@integer_regex, binary)
  end

  @doc """
  Parses a binary into a integer.
  Be sure it's a binary integer.

  ## Examples

  iex> Bookclub.TypeHelpers.parse_integer("21")
  21
  """
  @spec parse_integer(String.t()) :: integer()
  def parse_integer(binary), do: elem(Integer.parse(binary), 0)
end
