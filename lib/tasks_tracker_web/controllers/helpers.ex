defmodule TasksTrackerWeb.Controllers.Helpers do
  defmacro __using__(_opts) do
    quote do
      def respond_ok(conn) do
        conn |> put_status(:ok) |> json(%{"result" => "ok"})
      end

      def respond_created(conn) do
        conn |> put_status(:created) |> json(%{"result" => "ok"})
      end

      def respond_bad_request(conn, errors) do
        conn |> put_status(:bad_request) |> json(%{"result" => "error", "errors" => errors})
      end

      def respond_not_found(conn, errors) do
        conn |> put_status(:not_found) |> json(%{"result" => "error", "errors" => errors})
      end

      def changeset_errors_to_list(changeset) do
        changeset
        |> Ecto.Changeset.traverse_errors(fn {msg, opts} ->
          Enum.reduce(opts, msg, fn {key, value}, acc ->
            String.replace(acc, "%{#{key}}", to_string(value))
          end)
        end)
        |> Enum.reduce([], fn {key, errors}, acc ->
          ["#{key} #{Enum.join(errors, ", ")}" | acc]
        end)
      end
    end
  end
end
