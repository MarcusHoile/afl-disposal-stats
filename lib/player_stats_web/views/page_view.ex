defmodule PlayerStatsWeb.PageView do
  use PlayerStatsWeb, :view

  def line_chart_for_disposals(data) do
    data
    |> Enum.map(fn %{played_at: played_at, disposals: disposals} ->
      [played_at, disposals]
    end)
    |> Jason.encode!()
    |> Chartkick.line_chart(min: 5, max: 30)
  end
end
