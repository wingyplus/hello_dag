defmodule HelloDag do
  @moduledoc """
  Daggerize the `hello_dag` application!
  """

  use Dagger.Mod, name: "HelloDag"

  alias Dagger.{
    Client,
    Container,
    Directory
  }

  defstruct [:dag]

  @elixir_version "1.17.0-rc.0"
  @otp_version "27.0"
  @alpine_version "3.20.0"

  @elixir_image "hexpm/elixir:#{@elixir_version}-erlang-#{@otp_version}-alpine-#{@alpine_version}"
  @alpine_image "alpine:#{@alpine_version}"
  @postgresql_image "postgres:16-alpine"

  @function [
    args: [source: [type: Directory]],
    return: Container
  ]
  @doc """
  Run a unit tests suite.
  """
  def test(self, args) do
    self.dag
    |> with_base(args.source)
    |> Container.with_service_binding("postgresql", postgresql(self.dag))
    |> Container.with_env_variable("POSTGRES_HOST", "postgresql")
    |> Container.with_exec(~w[mix test --color])
  end

  @function [
    args: [source: [type: Directory]],
    return: Container
  ]
  @doc """
  Build the application.

  Returns the container after build.
  """
  def build(self, args) do
    release =
      self.dag
      |> with_base(args.source)
      |> Container.with_env_variable("MIX_ENV", "prod")
      |> Container.with_exec(~w[mix release])

    self.dag
    |> with_runtime()
    |> Container.with_user("nobody")
    |> Container.with_workdir("/app")
    |> Container.with_directory(
      "/app",
      Container.directory(release, "_build/prod/rel/hello_dag"),
      owner: "nobody:root"
    )
    |> Container.with_entrypoint(~w[./bin/server])
  end

  defp with_base(dag, source) do
    dag
    |> Client.container()
    |> Container.from(@elixir_image)
    |> Container.with_mounted_directory("/app", source)
    |> Container.with_workdir("/app")
    |> Container.with_exec(~w[apk add --no-cache git])
    |> Container.with_exec(~w[mix local.rebar --force])
    |> Container.with_exec(~w[mix local.hex --force])
    |> Container.with_exec(~w[mix deps.get])
  end

  defp with_runtime(dag) do
    dag
    |> Client.container()
    |> Container.from(@alpine_image)
    |> Container.with_exec(~w[apk add --no-cache libstdc++ openssl ncurses ca-certificates])
    |> Container.with_env_variable("LANG", "en_US.UTF-8")
    |> Container.with_env_variable("LANGUAGE", "en_US.UTF-8")
    |> Container.with_env_variable("LC_ALL", "en_US.UTF-8")
  end

  defp postgresql(dag) do
    dag
    |> Client.container()
    |> Container.from(@postgresql_image)
    |> Container.with_env_variable("POSTGRES_USER", "postgres")
    |> Container.with_env_variable("POSTGRES_PASSWORD", "postgres")
    |> Container.with_exposed_port(5432)
    |> Container.as_service()
  end
end
