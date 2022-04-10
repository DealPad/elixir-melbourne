defmodule ElixirMelbourne.Meetings.Question do
  use Ecto.Schema
  import Ecto.Changeset

  @fields [
    :room_id,
    :attendee_id,
    :content,
    :resolved_at
  ]

  @non_mandatory_fields [:resolved_at]

  schema "meetings_questions" do
    field(:content, :string)
    field(:room_id, :string)
    field(:resolved_at, :naive_datetime)
    belongs_to(:attendee, ElixirMelbourne.Meetings.Attendee, foreign_key: :attendee_id)

    has_many(
      :question_votes,
      ElixirMelbourne.Meetings.QuestionVote,
      foreign_key: :question_id,
      references: :id
    )

    timestamps()
  end

  @doc false
  def changeset(question, attrs) do
    question
    |> cast(attrs, @fields)
    |> validate_required(@fields -- @non_mandatory_fields)
  end
end
