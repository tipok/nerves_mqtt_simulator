defmodule Infosender.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Infosender.Supervisor]
    children =
      [
        {Tortoise.Supervisor, [
          name: Infosender.Connection.Supervisor,
          strategy: :one_for_one
        ]},
        {Infosender, %{topic: "foo/bar", numerator: 1, multiplicator: 4}},
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  def stop(_state) do
    #Tortoise.Connection.disconnect(Sine)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
      # Starts a worker by calling: Infosender.Worker.start_link(arg)
      # {Infosender.Worker, arg},
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      # Starts a worker by calling: Infosender.Worker.start_link(arg)
      # {Infosender.Worker, arg},
    ]
  end

  def target() do
    Application.get_env(:infosender, :target)
  end
end
