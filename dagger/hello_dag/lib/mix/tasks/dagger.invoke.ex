defmodule Mix.Tasks.Dagger.Invoke do
  use Mix.Task

  def run(_args) do
    Mix.ensure_application!(:inets)
    Application.ensure_all_started(:dagger)
    Application.ensure_all_started(:hello_dag)
    Dagger.Mod.invoke()
  end
end
