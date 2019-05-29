defmodule Bookclub.Chat.Presence do
  use Phoenix.Presence, otp_app: :bookclub,
                        pubsub_server: Bookclub.PubSub
end
