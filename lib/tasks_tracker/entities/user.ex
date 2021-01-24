defmodule TasksTracker.User do
  use Ecto.Schema
  use Pow.Ecto.Schema
  import Ecto.Changeset
  @supported_roles ~w(driver manager)

  schema "users" do
    field :full_name, :string
    field :phone, :string
    field :role, :string
    field :token, :string

    pow_user_fields()
    timestamps()
  end

  @doc false
  def changeset_to_create(user, role, attrs) do
    user
    |> cast(attrs, [:full_name, :phone])
    |> put_change(:role, role)
    |> generate_token()
    |> validate_inclusion(:role, @supported_roles)
    |> validate_required([:full_name, :phone, :role, :token])
  end

  defp generate_token(changeset) do
    changeset |> put_change(:token, UUID.uuid4())
  end
end
