defmodule Day01 do
  def first_star(input_stream) do
    input_stream |> Stream.map(fn line -> line |> String.replace(~r/[^\d]/, "") end)
                 |> Stream.map(fn line -> String.at(line, 0) <> String.at(line, -1) end)
                 |> Stream.map(fn line -> String.to_integer(line) end)
                 |> Enum.reduce(0, fn a, b -> a + b end)
  end
end

input_stream = File.stream!("inputs/day01.txt")
IO.puts(Day01.first_star(input_stream))
