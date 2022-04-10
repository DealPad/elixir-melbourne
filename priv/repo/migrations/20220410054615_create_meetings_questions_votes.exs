defmodule ElixirMelbourne.Repo.Migrations.CreateMeetingsQuestionsVotes do
  use Ecto.Migration

  def change do
    create table(:meetings_questions_votes) do
      add :attendee_id, references(:meetings_attendees, on_delete: :delete_all), null: false
      add :question_id, references(:meetings_questions, on_delete: :delete_all), null: false
      timestamps()
    end

    create unique_index(:meetings_questions_votes, [:attendee_id, :question_id],
             name: :uniq_meetings_questions_votes
           )
  end
end
