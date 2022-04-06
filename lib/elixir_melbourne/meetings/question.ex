defmodule ElixirMelbourne.Meetings.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meetings_questions" do


    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, [])
    |> validate_required([])
  end
end
