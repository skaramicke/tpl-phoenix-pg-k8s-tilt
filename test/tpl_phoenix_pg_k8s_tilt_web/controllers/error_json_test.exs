defmodule TplPhoenixPgK8sTiltWeb.ErrorJSONTest do
  use TplPhoenixPgK8sTiltWeb.ConnCase, async: true

  test "renders 404" do
    assert TplPhoenixPgK8sTiltWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert TplPhoenixPgK8sTiltWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
