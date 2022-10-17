defmodule CoreWeb.PageController do
  use CoreWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def about_us(conn, _params) do
    render(conn, "about_us.html")
  end

  def pricing(conn, _params) do
    render(conn, "pricing.html")
  end

  def faq(conn, _params) do
    render(conn, "faq.html")
  end
end
