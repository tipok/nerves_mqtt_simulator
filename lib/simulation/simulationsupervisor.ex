defmodule Infosender.Simulation.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      {Infosender.Simulation.Worker, %{topic: "foo/bar", numerator: 1, multiplicator: 4}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
