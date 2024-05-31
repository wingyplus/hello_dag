defmodule HelloDagTest do
  use ExUnit.Case
  doctest HelloDag

  test "greets the world" do
    assert HelloDag.hello() == :world
  end
end
