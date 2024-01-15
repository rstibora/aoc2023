defmodule Day01 do
  def first_star(input_stream) do
    input_stream |> Stream.map(fn line -> line |> String.replace(~r/[^\d]/, "") end)
                 |> Stream.map(fn line -> String.at(line, 0) <> String.at(line, -1) end)
                 |> Stream.map(fn line -> String.to_integer(line) end)
                 |> Enum.reduce(0, fn a, b -> a + b end)
  end

  defp replace_numbers(line) do
    line = String.replace(line, "one", "one1one")
    line = String.replace(line, "two", "two2two")
    line = String.replace(line, "three", "three3three")
    line = String.replace(line, "four", "four4four")
    line = String.replace(line, "five", "five5five")
    line = String.replace(line, "six", "six6six")
    line = String.replace(line, "seven", "seven7seven")
    line = String.replace(line, "eight", "eight8eight")
    line = String.replace(line, "nine", "nine9nine")
    line
  end

  def second_star(input_stream) do
    input_stream |> Stream.map(fn line -> replace_numbers(line) end)
                 |> first_star
  end
end
