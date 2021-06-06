defmodule PlayerStats.Schema.Page do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pages" do
    field :url, :string

    timestamps()
  end

  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:url])
    |> validate_required([:url])
  end
end
