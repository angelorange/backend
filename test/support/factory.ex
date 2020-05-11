defmodule Backend.Factory do
  use ExMachina.Ecto, repo: Backend.Repo
  use Backend.UserFactory
end
