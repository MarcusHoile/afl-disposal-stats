defmodule PlayerStats.Filter do
  @moduledoc """
  Schema for filtering params
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :current_year, :integer
    field :min_disposals, :integer, default: 0
    field :team_ids, {:array, :integer}, default: []
  end

  def build!(filter, attrs) do
    filter
    |> cast(attrs, [:current_year, :min_disposals, :team_ids])
    |> apply_action(:insert)
    |> case do
      {:ok, data} -> data
      error -> raise "bad filter params, #{inspect(error)}"
    end
  end
end
