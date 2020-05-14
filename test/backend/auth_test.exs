defmodule Backend.AuthTest do
  use Backend.DataCase

  import Backend.Factory
  alias Backend.Auth

  describe "users" do
    alias Backend.Auth.User

    test "list_users/0 returns all users" do
      user = insert(:user)
      assert [expected] = Auth.list_users()
      assert expected.id == user.id
      assert expected.email == user.email
      assert expected.password_hash == user.password_hash
    end

    test "get_user!/1 returns the user with given id" do
      user = insert(:user)

      assert subject = Auth.get_user!(user.id)

      assert subject.email == user.email
      assert subject.password_hash == user.password_hash
      assert subject.is_active == user.is_active
    end

    test "create_user/1 with valid data creates a user" do
      params = params_for(:user)

      assert {:ok, %User{} = subject} = Auth.create_user(params)
      assert params.email == subject.email
      assert params.is_active == subject.is_active
    end

    test "create_user/1 with invalid data returns error changeset" do
      params = %{}

      assert {:error, %Ecto.Changeset{}} = Auth.create_user(params)
    end

    test "update_user/2 with valid data updates the user" do
      user = insert(:user)
      params = params_for(:user)

      assert {:ok, %User{} = subject} = Auth.update_user(user, params)
      assert params.email == subject.email
      assert params.is_active == subject.is_active
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = insert(:user)
      params = %{email: 198}

      assert {:error, %Ecto.Changeset{}} = Auth.update_user(user, params)
    end

    test "delete_user/1 deletes the user" do
      user = insert(:user)

      assert {:ok, %User{}} = Auth.delete_user(user)
      assert_raise(Ecto.NoResultsError, fn -> Auth.get_user!(user.id) end)
    end
  end

  describe "autentification" do
    test "authentificate_user/2 returns :ok " do
      user = insert(:user)

      assert {:ok, %Auth.User{} = subject} = Auth.authentificate_user(user.email, user.password)
      assert subject.email == user.email
      assert subject.id == user.id
    end

    test "authentificate_user/2 returns :error" do
      user = insert(:user)

      assert {:error, _} = Auth.authentificate_user("#{user.email}br", "wilsonjr")
    end
  end
end
