defmodule PlayerStats.Schema.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :scraped, :boolean
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:scraped, :url])
    |> validate_required([:scraped, :url])
  end
end
