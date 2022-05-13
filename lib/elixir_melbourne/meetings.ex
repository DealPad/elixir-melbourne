defmodule ElixirMelbourne.Meetings do
  @moduledoc """
  The Meetings context.
  """

  import Ecto.Query, warn: false
  alias ElixirMelbourne.Repo

  alias ElixirMelbourne.Meetings.Question

  @doc """
  Returns the list of meetings_questions.

  ## Examples

      iex> list_meetings_questions()
      [%Question{}, ...]

  """
  def list_meetings_questions do
    Repo.all(Question)
  end

  def list_questions_by_room_id(room_id) do
    Question
    |> where([question], question.room_id == ^room_id)
    |> preload([:attendee, :question_votes])
    |> Repo.all()
    |> Enum.sort_by(&{Enum.count(&1.question_votes)}, :desc)
  end

  @doc """
  Gets a single question.

  Raises `Ecto.NoResultsError` if the Question does not exist.

  ## Examples

      iex> get_question!(123)
      %Question{}

      iex> get_question!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question!(id), do: Repo.get!(Question, id)
  def maybe_get_question(id), do: Repo.get(Question, id)

  def room_id_exists?(id) do
    Question
    |> where([question], question.room_id == ^id)
    |> Repo.exists?()
  end

  @doc """
  Creates a question.

  ## Examples

      iex> create_question(%{field: value})
      {:ok, %Question{}}

      iex> create_question(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question(attrs \\ %{}) do
    %Question{}
    |> Question.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question.

  ## Examples

      iex> update_question(question, %{field: new_value})
      {:ok, %Question{}}

      iex> update_question(question, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question(%Question{} = question, attrs) do
    question
    |> Question.changeset(attrs)
    |> Repo.update()
  end

  def resolve_question(question_id) do
    question_id
    |> maybe_get_question()
    |> update_question(%{resolved_at: NaiveDateTime.utc_now()})
  end

  def unresolve_question(question_id) do
    question_id
    |> maybe_get_question()
    |> update_question(%{resolved_at: nil})
  end

  @doc """
  Deletes a question.

  ## Examples

      iex> delete_question(question)
      {:ok, %Question{}}

      iex> delete_question(question)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question(%Question{} = question) do
    Repo.delete(question)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question changes.

  ## Examples

      iex> change_question(question)
      %Ecto.Changeset{data: %Question{}}

  """
  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  alias ElixirMelbourne.Meetings.Attendee

  @doc """
  Returns the list of meetings_attendees.

  ## Examples

      iex> list_meetings_attendees()
      [%Attendee{}, ...]

  """
  def list_meetings_attendees do
    Repo.all(Attendee)
  end

  @doc """
  Gets a single attendee.

  Raises `Ecto.NoResultsError` if the Attendee does not exist.

  ## Examples

      iex> get_attendee!(123)
      %Attendee{}

      iex> get_attendee!(456)
      ** (Ecto.NoResultsError)

  """
  def get_attendee!(id), do: Repo.get!(Attendee, id)
  def maybe_get_attendee(id), do: Repo.get(Attendee, id)

  @doc """
  Creates a attendee.

  ## Examples

      iex> create_attendee(%{field: value})
      {:ok, %Attendee{}}

      iex> create_attendee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_attendee(attrs \\ %{}) do
    %Attendee{}
    |> Attendee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a attendee.

  ## Examples

      iex> update_attendee(attendee, %{field: new_value})
      {:ok, %Attendee{}}

      iex> update_attendee(attendee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_attendee(%Attendee{} = attendee, attrs) do
    attendee
    |> Attendee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a attendee.

  ## Examples

      iex> delete_attendee(attendee)
      {:ok, %Attendee{}}

      iex> delete_attendee(attendee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_attendee(%Attendee{} = attendee) do
    Repo.delete(attendee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking attendee changes.

  ## Examples

      iex> change_attendee(attendee)
      %Ecto.Changeset{data: %Attendee{}}

  """
  def change_attendee(%Attendee{} = attendee, attrs \\ %{}) do
    Attendee.changeset(attendee, attrs)
  end

  alias ElixirMelbourne.Meetings.QuestionVote

  @doc """
  Returns the list of meetings_questions_votes.

  ## Examples

      iex> list_meetings_questions_votes()
      [%QuestionVote{}, ...]

  """
  def list_meetings_questions_votes do
    Repo.all(QuestionVote)
  end

  @doc """
  Gets a single question_vote.

  Raises `Ecto.NoResultsError` if the Question vote does not exist.

  ## Examples

      iex> get_question_vote!(123)
      %QuestionVote{}

      iex> get_question_vote!(456)
      ** (Ecto.NoResultsError)

  """
  def get_question_vote!(id), do: Repo.get!(QuestionVote, id)
  def get_question_vote_by(attrs), do: Repo.get_by(QuestionVote, attrs)

  @doc """
  Creates a question_vote.

  ## Examples

      iex> create_question_vote(%{field: value})
      {:ok, %QuestionVote{}}

      iex> create_question_vote(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_question_vote(attrs \\ %{}) do
    %QuestionVote{}
    |> QuestionVote.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a question_vote.

  ## Examples

      iex> update_question_vote(question_vote, %{field: new_value})
      {:ok, %QuestionVote{}}

      iex> update_question_vote(question_vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_question_vote(%QuestionVote{} = question_vote, attrs) do
    question_vote
    |> QuestionVote.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a question_vote.

  ## Examples

      iex> delete_question_vote(question_vote)
      {:ok, %QuestionVote{}}

      iex> delete_question_vote(question_vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_question_vote(%QuestionVote{} = question_vote) do
    Repo.delete(question_vote)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking question_vote changes.

  ## Examples

      iex> change_question_vote(question_vote)
      %Ecto.Changeset{data: %QuestionVote{}}

  """
  def change_question_vote(%QuestionVote{} = question_vote, attrs \\ %{}) do
    QuestionVote.changeset(question_vote, attrs)
  end
end
