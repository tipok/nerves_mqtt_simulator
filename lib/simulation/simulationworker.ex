defmodule Infosender.Simulation.Worker do
  use GenServer
  require Logger

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  defp schedule_work() do
    Process.send_after(self(), :work, 1_000)
  end

  @impl true
  def init(state=%{topic: topic, multiplicator: multiplicator}) do
    debug = Map.get(state, :debug, false)
    Logger.info("Starting simulator for topic '#{topic}' debug: #{debug}")
    if debug do
      Tortoise.Connection.subscribe(Sine, topic, [qos: 0])
    end

    schedule_work()
    {:ok, %{topic: topic, numerator: 1, multiplicator: multiplicator}}
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
