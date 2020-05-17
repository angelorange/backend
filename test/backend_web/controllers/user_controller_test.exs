defmodule BackendWeb.UserControllerTest do
  use BackendWeb.ConnCase

  # alias Backend.Auth
  alias Backend.Auth.User
  # alias Plug.Test

  import Backend.Factory

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  def login(conn, %{email: email}) do
    post(
      conn,
      Routes.user_path(conn, :sign_in, %{
        email: email,
        password: "123456"
      })
    )
  end

  describe "index" do
    test "lists all users", %{conn: conn} do
      user = insert(:user)
      insert(:user)

      conn =
        login(conn, user)
        |> get(Routes.user_path(conn, :index))

      assert [ subject | _rest ] = json_response(conn, 200)["data"]
      assert subject == %{"email" => user.email , "id" => user.id , "is_active" => user.is_active }
    end
  end

  describe "create user" do
    test "renders user when data is valid", %{conn: conn} do
      params = params_for(:user)

      conn = post(conn, Routes.user_path(conn, :create), user: params)

      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert subject = json_response(conn, 200)["data"]
      assert %{
        "id" => id,
        "email" => params.email,
        "is_active" => params.is_active
      } == subject
    end

    test "renders errors when data is invalid", %{conn: conn} do
      params = %{}
      conn = post(conn, Routes.user_path(conn, :create), user: params)
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update user" do
    setup [:create_user]

    test "renders user when data is valid", %{conn: conn, user: %User{id: id} = user} do
      params = params_for(:user, %{email: "aa@gmail.com"})

      conn =
        login(conn, user)
        |> put(Routes.user_path(conn, :update, user), user: params)
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get(conn, Routes.user_path(conn, :show, id))

      assert %{
               "id" => id,
               "email" => "aa@gmail.com",
               "is_active" => true
             } = json_response(conn, 200)["data"]
    end

    test "renders errors when data is invalid", %{conn: conn, user: user} do
      params = %{}

      conn =
        login(conn, user)
        |> put( Routes.user_path(conn, :update, user), user: params)
      assert json_response(conn, 422)["errors"] == %{"detail" => "Unprocessable Entity"}
    end
  end

  describe "delete user" do
    setup [:create_user]

    test "deletes chosen user", %{conn: conn, user: user} do
      conn =
        login(conn, user)
        |> delete(Routes.user_path(conn, :delete, user))
      assert response(conn, 204)

      assert_error_sent 404, fn ->
        get(conn, Routes.user_path(conn, :show, user))
      end
    end
  end

  describe "sign in user" do
    test "renders user when auth ok", %{conn: conn} do
      user = insert(:user)

      conn =
        post(conn, Routes.user_path(conn, :sign_in, %{email: user.email, password: user.password}))

      assert %{"user" => subject} = json_response(conn, 200)["data"]
      assert subject["email"] == user.email
      assert subject["id"] == user.id
    end

    test "renders error when status 401", %{conn: conn} do
      conn =
        post(conn, Routes.user_path(conn, :sign_in, %{email: nil, password: nil}))

      assert %{"detail" => "Unauthorized"} = json_response(conn, 401)["errors"]
    end
  end

  defp create_user(_) do
    user = insert(:user)
    %{user: user}
  end


end
