defmodule CoreWeb.PageController do
  use CoreWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def socials(conn, _params) do
    render(conn, "socials.html")
  end

  def discord(conn, _params) do
    render(conn, "discord.html")
  end

  def about(conn, _params) do
    render(conn, "about.html")
  end

  def projects(conn, _params) do
    render(conn, "projects.html")
  end

  def contact(conn, _params) do
    render(conn, "contact.html")
  end
end
