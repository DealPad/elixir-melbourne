defmodule ElixirMelbourne.Repo.Migrations.AddStatusToQuestion do
  use Ecto.Migration

  def change do
    alter table(:meetings_questions) do
      add :resolved_at, :naive_datetime
    end
  end
end
