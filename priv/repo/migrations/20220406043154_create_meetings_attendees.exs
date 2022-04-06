defmodule ElixirMelbourne.Repo.Migrations.CreateMeetingsAttendees do
  use Ecto.Migration

  def change do
    create table(:meetings_attendees) do
      add :username, :string
      timestamps()
    end
  end
end
