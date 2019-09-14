defmodule Infosender.Simulation.Supervisor do
  use Supervisor
  require Logger

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
    simulations = Application.get_env(:infosender, Infosender.Simulation, [])
    children = simulations
    |> Enum.with_index(1)
    |> Enum.map(fn {sim_config, i} -> Supervisor.child_spec(
      {Infosender.Simulation.Worker, [id: :"sim-worker-#{i}", config: sim_config]},
      id: :"sim-worker-#{i}"
    ) end)

    Logger.info("#{inspect(children)}")

    Supervisor.init(children, strategy: :one_for_one)
  end
end
