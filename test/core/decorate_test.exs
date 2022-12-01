defmodule Core.DecorateTest do
  use Core.DataCase
  import Core.UsersFixtures

  doctest Core.Decorate

  setup :create_account
  setup :with_name_options

end
