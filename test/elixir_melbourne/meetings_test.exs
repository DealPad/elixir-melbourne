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

  describe "meetings_attendees" do
    alias ElixirMelbourne.Meetings.Attendee

    import ElixirMelbourne.MeetingsFixtures

    @invalid_attrs %{}

    test "list_meetings_attendees/0 returns all meetings_attendees" do
      attendee = attendee_fixture()
      assert Meetings.list_meetings_attendees() == [attendee]
    end

    test "get_attendee!/1 returns the attendee with given id" do
      attendee = attendee_fixture()
      assert Meetings.get_attendee!(attendee.id) == attendee
    end

    test "create_attendee/1 with valid data creates a attendee" do
      valid_attrs = %{}

      assert {:ok, %Attendee{} = attendee} = Meetings.create_attendee(valid_attrs)
    end

    test "create_attendee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meetings.create_attendee(@invalid_attrs)
    end

    test "update_attendee/2 with valid data updates the attendee" do
      attendee = attendee_fixture()
      update_attrs = %{}

      assert {:ok, %Attendee{} = attendee} = Meetings.update_attendee(attendee, update_attrs)
    end

    test "update_attendee/2 with invalid data returns error changeset" do
      attendee = attendee_fixture()
      assert {:error, %Ecto.Changeset{}} = Meetings.update_attendee(attendee, @invalid_attrs)
      assert attendee == Meetings.get_attendee!(attendee.id)
    end

    test "delete_attendee/1 deletes the attendee" do
      attendee = attendee_fixture()
      assert {:ok, %Attendee{}} = Meetings.delete_attendee(attendee)
      assert_raise Ecto.NoResultsError, fn -> Meetings.get_attendee!(attendee.id) end
    end

    test "change_attendee/1 returns a attendee changeset" do
      attendee = attendee_fixture()
      assert %Ecto.Changeset{} = Meetings.change_attendee(attendee)
    end
  end

  describe "meetings_questions_votes" do
    alias ElixirMelbourne.Meetings.QuestionVote

    import ElixirMelbourne.MeetingsFixtures

    @invalid_attrs %{}

    test "list_meetings_questions_votes/0 returns all meetings_questions_votes" do
      question_vote = question_vote_fixture()
      assert Meetings.list_meetings_questions_votes() == [question_vote]
    end

    test "get_question_vote!/1 returns the question_vote with given id" do
      question_vote = question_vote_fixture()
      assert Meetings.get_question_vote!(question_vote.id) == question_vote
    end

    test "create_question_vote/1 with valid data creates a question_vote" do
      valid_attrs = %{}

      assert {:ok, %QuestionVote{} = question_vote} = Meetings.create_question_vote(valid_attrs)
    end

    test "create_question_vote/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meetings.create_question_vote(@invalid_attrs)
    end

    test "update_question_vote/2 with valid data updates the question_vote" do
      question_vote = question_vote_fixture()
      update_attrs = %{}

      assert {:ok, %QuestionVote{} = question_vote} =
               Meetings.update_question_vote(question_vote, update_attrs)
    end

    test "update_question_vote/2 with invalid data returns error changeset" do
      question_vote = question_vote_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Meetings.update_question_vote(question_vote, @invalid_attrs)

      assert question_vote == Meetings.get_question_vote!(question_vote.id)
    end

    test "delete_question_vote/1 deletes the question_vote" do
      question_vote = question_vote_fixture()
      assert {:ok, %QuestionVote{}} = Meetings.delete_question_vote(question_vote)
      assert_raise Ecto.NoResultsError, fn -> Meetings.get_question_vote!(question_vote.id) end
    end

    test "change_question_vote/1 returns a question_vote changeset" do
      question_vote = question_vote_fixture()
      assert %Ecto.Changeset{} = Meetings.change_question_vote(question_vote)
    end
  end
end
