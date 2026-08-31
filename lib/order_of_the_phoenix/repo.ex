defmodule OrderOfThePhoenix.Repo do
  use Ecto.Repo,
    otp_app: :order_of_the_phoenix,
    adapter: Ecto.Adapters.Postgres
end
