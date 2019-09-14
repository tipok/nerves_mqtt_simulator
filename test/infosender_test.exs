defmodule InfosenderTest do
  use ExUnit.Case
  doctest Infosender

  test "greets the world" do
    assert Infosender.hello() == :world
  end
end
