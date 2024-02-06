defmodule Aoc2023 do
  def main do
    day_string = "04"

    input_stream = File.stream!("inputs/day#{day_string}.txt")
    # Day03.first_star(input_stream)
    Day04.first_star(input_stream)
  end
end
