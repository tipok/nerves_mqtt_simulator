defmodule Infosender.Simulation.Worker do
  use GenServer
  require Logger

  def start_link(default \\ %{numerator: 1, multiplicator: 4}) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 1_000)
  end

  @impl true
  def init(state=%{topic: topic}) do
    Tortoise.Supervisor.start_child(
      Infosender.Connection.Supervisor,
      client_id: Sine,
      server: {Tortoise.Transport.Tcp, host: 'localhost', port: 1883},
      handler: {Infosender.Infohandler, []}
    )
    Tortoise.Connection.subscribe(Sine, topic, [qos: 0])
    schedule_work()
    {:ok, state}
  end

  @impl true
  def handle_info(:work, state=%{topic: topic, numerator: numerator, multiplicator: multiplicator}) do
    current_angle = :math.pi() * (numerator / 4)
    current_value = :math.sin(current_angle) * multiplicator
    payload = <<current_value::float-64>>
    Tortoise.publish(Sine, topic, payload)
    schedule_work()
    {:noreply, Map.put(state, :numerator, numerator+1)}
  end

  def handle_info({{Tortoise, Sine}, _, status}, state=%{topic: topic}) do
    if status != :ok do
      Logger.error("Could not subscribe to: #{topic}")
    end
    {:noreply, state}
  end

  @impl true
  def terminate(_reason, _state) do
    Logger.error("The server terminated")
  end
end
