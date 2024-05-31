defmodule HelloDag.Repo do
  use Ecto.Repo,
    otp_app: :hello_dag,
    adapter: Ecto.Adapters.Postgres
end
