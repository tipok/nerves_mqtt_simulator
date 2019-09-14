defmodule Infosender.Infohandler do
  use Tortoise.Handler
  require Logger

  @impl true
  def init(_) do
    {:ok, %{}}
  end

  @impl true
  def handle_message(topic, <<current_value::float-64>>, state) do
    topic = Enum.join(topic, "/")
    Logger.info("Got message from: #{topic} with value: #{current_value}")
    #next_actions = [{:unsubscribe, topic}]
    next_actions = []
    {:ok, state, next_actions}
  end
end
