defmodule ElixirMelbourne.Repo.Migrations.AddRoomIdIntoMeetingsQuestions do
  use Ecto.Migration

  def change do
    alter table(:meetings_questions) do
      add :room_id, :string
    end
  end
end
