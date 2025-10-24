defmodule TplPhoenixPgK8sTiltWeb.PageController do
  use TplPhoenixPgK8sTiltWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
