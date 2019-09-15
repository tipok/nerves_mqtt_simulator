defmodule Infosender.Simulation.Supervisor do
  use Supervisor
  require Logger

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    mqtt_config = Application.get_env(:infosender, :mqtt, [])
    client_id = Keyword.get(mqtt_config, :client_id, Sine)
    host = Keyword.get(mqtt_config, :host, "localhost")
    port = Keyword.get(mqtt_config, :port, 1883)

    server_config = case Keyword.get(mqtt_config, :ssl, []) do
      ssl when is_list(ssl) and length(ssl) > 0 ->
        transport_config = [host: host, port: port] ++ ssl
        {Tortoise.Transport.SSL, transport_config}
      _ -> {Tortoise.Transport.Tcp, host: host, port: port}
    end

    Tortoise.Supervisor.start_child(
      Infosender.Connection.Supervisor,
      client_id: client_id,
      server: server_config,
      handler: {Infosender.Infohandler, []}
    )
    simulations = Application.get_env(:infosender, Infosender.Simulation, [])
    children = simulations
    |> Enum.with_index(1)
    |> Enum.map(fn {sim_config, i} -> Supervisor.child_spec(
      {Infosender.Simulation.Worker, [id: :"sim-worker-#{i}", config: Map.put(sim_config, :client_id, client_id)]},
      id: :"sim-worker-#{i}"
    ) end)

    Supervisor.init(children, strategy: :one_for_one)
  end
end
