defmodule ElixirMelbourne.Meetings.Attendee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meetings_attendees" do
    field(:username, :string)

    timestamps()
  end

  @doc false
  def changeset(attendee, attrs) do
    attendee
    |> cast(attrs, [:username])
    |> validate_required([:username])
  end
end
