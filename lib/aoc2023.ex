defmodule Aoc2023 do
  def main do
    day_string = "02"

    input_stream = File.stream!("inputs/day#{day_string}.txt")
    Day02.second_star(input_stream)
  end
end
