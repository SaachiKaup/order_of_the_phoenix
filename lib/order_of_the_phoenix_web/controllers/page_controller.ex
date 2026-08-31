defmodule OrderOfThePhoenixWeb.PageController do
  use OrderOfThePhoenixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
