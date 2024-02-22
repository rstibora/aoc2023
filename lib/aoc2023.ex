defmodule Aoc2023 do
  def main do
    day_string = "05"

    input_stream = File.stream!("inputs/day#{day_string}.txt")
    # Day03.first_star(input_stream)
    Day05.first_start(input_stream)
  end
end
