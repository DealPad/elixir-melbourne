defmodule ElixirMelbourne.Repo.Migrations.CreateMeetingsQuestions do
  use Ecto.Migration

  def change do
    create table(:meetings_questions) do
      add :name, :string, comment: "Name of the person asking questions"
      add :content, :text, comment: "Question content"
      add :votes, :integer, comment: "Number of people live the question"
      add :invalidated, :boolean, default: false
      timestamps()
    end
  end
end
