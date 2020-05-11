defmodule Backend.UserFactory do
  defmacro __using__(_opts) do
    quote do
      def user_factory do
        %Backend.Auth.User{
          email: Faker.Internet.free_email(),
          password: "123456",
          password_hash: Bcrypt.hash_pwd_salt("123456"),
          is_active: true
        }
      end
    end
  end
end
