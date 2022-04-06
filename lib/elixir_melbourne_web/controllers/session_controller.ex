defmodule ElixirMelbourneWeb.SessionController do
  use ElixirMelbourneWeb, :controller

  def set(conn, %{"username" => username}), do: store_string(conn, :username, username)

  defp store_string(conn, key, value) do
    conn
    |> put_session(key, value)
    |> json("success")
  end
end
