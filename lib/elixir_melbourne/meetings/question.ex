defmodule ElixirMelbourne.Meetings.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :room_id,
    :attendee_id,
    :content
  ]

  schema "meetings_questions" do
    field(:content, :string)
    field(:room_id, :string)
    belongs_to(:attebdee, ElixirMelbourne.Meetings.Attendee, foreign_key: :attendee_id)
    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, @fields)
    |> validate_required(@fields)
  end
end
