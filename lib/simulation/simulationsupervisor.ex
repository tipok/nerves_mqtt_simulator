defmodule Infosender.Simulation.Supervisor do
  use Supervisor

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    Tortoise.Supervisor.start_child(
      Infosender.Connection.Supervisor,
      client_id: Sine,
      server: {Tortoise.Transport.Tcp, host: 'localhost', port: 1883},
      handler: {Infosender.Infohandler, []}
    )
    children = [
      {Infosender.Simulation.Worker, %{topic: "foo/bar", numerator: 1, multiplicator: 4}}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
