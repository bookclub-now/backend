defmodule Bookclub.Helpers do
  @moduledoc """
    This module is automatically imported for all controllers to provide
    a custom way to send errors to the client
  """

  import Plug.Conn, only: [put_status: 2]
  import Phoenix.Controller, only: [render: 3, put_view: 2]
  alias BookclubWeb.ErrorView
  alias Ecto.Changeset

  def send_error(conn, code, message) when is_binary(message) do
    conn |> prepare_send_error(code) |> render("#{code}.json", %{errors: message})
  end

  def send_error(conn, code, changeset) do
    errors = extract_changeset_errors(changeset)
    conn |> prepare_send_error(code) |> render("#{code}.json", %{errors: errors})
  end

  @doc "Converts meters to miles"
  def meters_to_miles(meters), do: meters / 1609.344

  @doc "Converts miles to meters"
  def miles_to_meters(miles), do: miles * 1609.344

  @doc "Converts to American date"
  def to_date(date) do
    [date.year, date.month, date.day]
    |> Stream.map(&to_string/1)
    |> Stream.map(&String.pad_leading(&1, 2, "0"))
    |> Enum.join("-")
  end

  @doc "Converts to only numbers"
  def to_only_numbers(str) do
    Regex.replace(~r/[^0-9]/, str, "")
  end

  defp extract_changeset_errors(changeset) do
    Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  defp prepare_send_error(conn, code) do
    conn
    |> put_status(code)
    |> put_view(ErrorView)
  end
end
