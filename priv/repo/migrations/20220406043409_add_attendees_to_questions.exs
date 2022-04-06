defmodule ElixirMelbourne.Repo.Migrations.AddAttendeesToQuestions do
  use Ecto.Migration

  def change do
    alter table(:meetings_questions) do
      add :attendee_id, references(:meetings_attendees, on_delete: :delete_all), null: false
    end
  end
end
