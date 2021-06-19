defmodule PlayerStatsWeb.PageView do
  use PlayerStatsWeb, :view

  def line_chart_for_disposals(data) do
    data
    |> Enum.map(fn %{round: round, disposals: disposals} ->
      [round, disposals]
    end)
    |> Jason.encode!()
    |> IO.inspect()
    |> Chartkick.line_chart(min: 5, max: 30)
  end

  # data
  # |> Enum.map(fn %{round: round, disposals: disposals} ->
  #   {"Round #{round}", disposals}
  # end)
  # |> Enum.into(%{})
  # |> Jason.encode!()
  # |> IO.inspect()
  # |> Chartkick.line_chart()
end
