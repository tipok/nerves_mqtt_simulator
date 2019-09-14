# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :infosender,
  target: Mix.target(),
  simulation: true

config :infosender, Infosender.Simulation, [
    %{topic: "foo/bar", multiplicator: 4, debug: true},
    %{topic: "bla/blub", multiplicator: 8, debug: true},
  ]

# Customize non-Elixir parts of the firmware. See
# https://hexdocs.pm/nerves/advanced-configuration.html for details.

config :nerves, :firmware, rootfs_overlay: "rootfs_overlay"

# Use shoehorn to start the main application. See the shoehorn
# docs for separating out critical OTP applications such as those
# involved with firmware updates.

config :shoehorn,
  init: [:nerves_runtime, :nerves_init_gadget],
  app: Mix.Project.config()[:app]

# Use Ringlogger as the logger backend and remove :console.
# See https://hexdocs.pm/ring_logger/readme.html for more information on
# configuring ring_logger.

logger_backends = case Mix.env do
  :prod -> [RingLogger]
  _ -> [RingLogger, :console]
end

config :logger, backends: logger_backends


config :nerves_time, :servers, [
  "0.pool.ntp.org",
  "1.pool.ntp.org",
  "2.pool.ntp.org",
  "3.pool.ntp.org"
]

if Mix.target() != :host do
  import_config "target.exs"
end
