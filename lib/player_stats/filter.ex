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
    field :max_avg_disposals, :integer
    field :team_ids, {:array, :integer}, default: []
    field :rounds, :integer, default: 2
  end

  def build!(attrs) do
    %__MODULE__{}
    |> cast(attrs, [:current_year, :max_avg_disposals, :min_disposals, :team_ids, :rounds])
    |> apply_action(:insert)
    |> case do
      {:ok, data} -> data
      error -> raise "bad filter params, #{inspect(error)}"
    end
  end
end
