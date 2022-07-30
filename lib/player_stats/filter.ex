defmodule PlayerStats.Filter do
  @moduledoc """
  Schema for filtering params
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  embedded_schema do
    field :current_year, :integer
    field :filter_by_streak, :boolean, default: false
    field :filter_by_recent_form, :boolean, default: true
    field :min_disposals, :integer, default: 0
    field :min_goals, :integer, default: 0
    field :min_streak, :integer, default: 2
    field :sort_by, :string, default: "form"
    field :sort_direction, :string, default: "desc"
    field :team_ids, {:array, :integer}, default: []
  end

  def build!(filter, attrs) do
    filter
    |> cast(attrs, [
      :current_year,
      :filter_by_recent_form,
      :filter_by_streak,
      :min_disposals,
      :min_goals,
      :min_streak,
      :sort_by,
      :sort_direction,
      :team_ids
    ])
    |> apply_action(:insert)
    |> case do
      {:ok, data} -> data
      error -> raise "bad filter params, #{inspect(error)}"
    end
  end
end
