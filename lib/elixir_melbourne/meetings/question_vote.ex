defmodule ElixirMelbourne.Meetings.QuestionVote do
  use Ecto.Schema
  import Ecto.Changeset

  @field [
    :attendee_id,
    :question_id
  ]

  schema "meetings_questions_votes" do
    belongs_to(:attendee, ElixirMelbourne.Meetings.Attendee, foreign_key: :attendee_id)
    belongs_to(:question, ElixirMelbourne.Meetings.Question, foreign_key: :question_id)

    timestamps()
  end

  @doc false
  def changeset(question_vote, attrs) do
    question_vote
    |> cast(attrs, @field)
    |> validate_required(@field)
    |> unique_constraint([:attendee_id, :question_id], name: :uniq_meetings_questions_votes)
  end
end
