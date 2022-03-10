defmodule ElixirMelbourne.MeetingsTest do
  use ElixirMelbourne.DataCase

  alias ElixirMelbourne.Meetings

  describe "meetings_questions" do
    alias ElixirMelbourne.Meetings.Question

    import ElixirMelbourne.MeetingsFixtures

    @invalid_attrs %{}

    test "list_meetings_questions/0 returns all meetings_questions" do
      question = question_fixture()
      assert Meetings.list_meetings_questions() == [question]
    end

    test "get_question!/1 returns the question with given id" do
      question = question_fixture()
      assert Meetings.get_question!(question.id) == question
    end

    test "create_question/1 with valid data creates a question" do
      valid_attrs = %{}

      assert {:ok, %Question{} = question} = Meetings.create_question(valid_attrs)
    end

    test "create_question/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meetings.create_question(@invalid_attrs)
    end

    test "update_question/2 with valid data updates the question" do
      question = question_fixture()
      update_attrs = %{}

      assert {:ok, %Question{} = question} = Meetings.update_question(question, update_attrs)
    end

    test "update_question/2 with invalid data returns error changeset" do
      question = question_fixture()
      assert {:error, %Ecto.Changeset{}} = Meetings.update_question(question, @invalid_attrs)
      assert question == Meetings.get_question!(question.id)
    end

    test "delete_question/1 deletes the question" do
      question = question_fixture()
      assert {:ok, %Question{}} = Meetings.delete_question(question)
      assert_raise Ecto.NoResultsError, fn -> Meetings.get_question!(question.id) end
    end

    test "change_question/1 returns a question changeset" do
      question = question_fixture()
      assert %Ecto.Changeset{} = Meetings.change_question(question)
    end
  end
end
