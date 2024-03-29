defmodule Infosender.Simulation.Worker do
  use GenServer
  require Logger

  def start_link([id: id, config: config]) do
    GenServer.start_link(__MODULE__, config, name: id)
  end

  defp schedule_work(interval) do
    Process.send_after(self(), :work, interval)
  end

  defp sinus(numerator, max) do
    current_angle = :math.pi() * (numerator / 4)
    current_value = :math.sin(current_angle) * max
    numerator = case numerator == max do
      true -> 1
      false -> numerator + 1
    end
    {numerator, <<current_value::float-64>>}
  end

  defp cosinus(numerator, max) do
    current_angle = :math.pi() * (numerator / 4)
    current_value = :math.cos(current_angle) * max
    numerator = case numerator == max do
      true -> 1
      false -> numerator + 1
    end
    {numerator, <<current_value::float-64>>}
  end

  defp step(1, max) do
    step({0, 1}, max)
  end

  defp step({numerator, step}, max) do
    current_value = numerator + step
    step = cond do
      current_value + max == 0 -> -step
      current_value - max == 0 -> -step
      true -> step
    end
    {{current_value, step}, <<current_value::float-64>>}
  end

  @impl true
  def init(state=%{client_id: client_id, topic: topic, func: func, max: max}) do
    debug = Map.get(state, :debug, false)
    interval = Map.get(state, :interval, 1_000)
    Logger.info("Starting simulator for topic '#{topic}' debug: #{debug}")
    if debug do
      Tortoise.Connection.subscribe(client_id, topic, [qos: 0])
    end

    f = case func do
      :sin -> &sinus/2
      :cos -> &cosinus/2
      :step -> &step/2
      _ -> raise ArgumentError, message: ":func #{inspect(func)} is not supported"
    end

    schedule_work(interval)
    {:ok, %{client_id: client_id, interval: interval, topic: topic, func: f, numerator: 1, max: max}}
  end

  @impl true
  def handle_info(:work, state=%{client_id: client_id, interval: interval, topic: topic, func: func, numerator: numerator, max: max}) do
    {numerator, payload} = func.(numerator, max)
    Tortoise.publish(client_id, topic, payload)
    schedule_work(interval)
    {:noreply, Map.put(state, :numerator, numerator)}
  end

  @impl true
  def handle_info({{Tortoise, _}, _, status}, state=%{topic: topic}) do
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
