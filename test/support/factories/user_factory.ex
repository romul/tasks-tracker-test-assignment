defmodule TasksTracker.UserFactory do
  defmacro __using__(_opts) do
    quote do
      alias TasksTracker.{User, Repo}

      def manager_factory do
        %User{
          role: "manager",
          full_name: "Alex Sergeyev",
          phone: "+79876543210",
          token: UUID.uuid4()
        }
      end

      def driver_factory do
        %User{
          role: "driver",
          full_name: "John Smith",
          phone: "+79876543211",
          token: UUID.uuid4()
        }
      end

      def get_users_count do
        Repo.aggregate(User, :count, :id)
      end
    end
  end
end
