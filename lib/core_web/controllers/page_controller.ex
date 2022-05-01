defmodule CoreWeb.PageController do
  use CoreWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def show(conn, %{"id" => "socials"}) do
    render(conn, "socials.html")
  end

  def show(conn, %{"id" => "discord"}) do
    render(conn, "discord.html")
  end

  def show(conn, %{"id" => "about"}) do
    render(conn, "about.html")
  end

  def show(conn, %{"id" => "projects"}) do
    render(conn, "projects.html")
  end

  def show(conn, %{"id" => "contact"}) do
    render(conn, "contact.html")
  end
end
