import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :client_admin, ClientAdminWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "g50qkrSPWt5p2d+JI0tFiZA4UnR4ZSeoYkIGJWk4lbX9GZ46NDv1Yq1qN5VGDTfN",
  server: false

config :mongodb, :mongo,
  url: "mongodb://mongo:27017/client_admin_test",
  pool_size: 5

config :client_admin, :mongo_url, "mongodb://mongo:27017/client_admin_test"

config :client_admin, mongo_db: :mongo

config :logger, level: :warn

# In test we don't send emails
config :client_admin, ClientAdmin.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true
