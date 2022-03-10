defmodule ElixirMelbourne.Meetings.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :name, :content, :votes
  ]

  schema "meetings_questions" do
    field(:name, :string)
    field(:content, :string)
    field(:votes, :integer)
    field(:invalidated, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, @fields)
  end
end
