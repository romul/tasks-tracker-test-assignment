defmodule TasksTracker.UsersTest do
  use TasksTracker.DataCase
  alias TasksTracker.{User, Users}

  setup do
    [user_params: %{full_name: "John Smith", phone: "+79876543210"}]
  end

  describe "create_driver/2" do
    test "returns an error when some required attributes are missing", _ctx do
      assert get_users_count() == 0
      {:error, _} = Users.create_driver(%{})
      assert get_users_count() == 0
    end

    test "creates a task when all params present", ctx do
      assert {:ok, %User{role: "driver"}} = Users.create_driver(ctx.user_params)
    end
  end

  describe "create_manager/2" do
    test "returns an error when some required attributes are missing", _ctx do
      assert get_users_count() == 0
      {:error, _} = Users.create_manager(%{})
      assert get_users_count() == 0
    end

    test "creates a task when all params present", ctx do
      assert {:ok, %User{role: "manager"}} = Users.create_manager(ctx.user_params)
    end
  end
end
