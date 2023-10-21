import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :nba_lottery, NbaLotteryWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "R4i/URld7+A3T9uhZviZn2uCFr4vjBha8SnG3/bi/gUlpDMsS+CRle9XeVfAkrZW",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
