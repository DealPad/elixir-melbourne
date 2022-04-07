defmodule ElixirMelbourne.Repo.Migrations.CreateMeetingsQuestions do
  use Ecto.Migration

  def change do
    create table(:meetings_questions) do
      add :content, :string, comment: "question content"

      timestamps()
    end
  end
end
