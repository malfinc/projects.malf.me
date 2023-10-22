defmodule Core.Users.AccountNotifier do
  @moduledoc false
  import Swoosh.Email

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({
        Application.get_env(:core, :application_name),
        Application.get_env(:core, :support_email_address)
      })
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Core.Mailer.deliver(email) do
      {:ok, email}
    end
  end
end
