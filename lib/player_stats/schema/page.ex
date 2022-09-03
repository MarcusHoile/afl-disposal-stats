defmodule PlayerStats.Schema.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :path, :string
    field :scraped, :boolean
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:path, :scraped, :url])
    |> validate_required([:path, :scraped, :url])
  end
end
