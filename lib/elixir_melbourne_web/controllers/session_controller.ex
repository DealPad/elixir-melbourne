defmodule ElixirMelbourneWeb.SessionController do
  use ElixirMelbourneWeb, :controller
  alias ElixirMelbourne.Meetings

  def set(conn, %{"return_to" => return_to, "username" => username}) do
    case Meetings.create_attendee(%{username: username}) do
      {:ok, %Meetings.Attendee{id: attendee_id}} ->
        conn
        |> put_session(:attendee_id, attendee_id)
        |> redirect(to: return_to)

      _ ->
        conn
        |> put_status(401)
    end
  end
end
