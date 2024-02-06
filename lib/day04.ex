defmodule Day04 do
  defmodule Card do
    defstruct winning_numbers: MapSet.new([]), numbers: []
  end

  defp parse_cards(input_stream) do
    Enum.reduce(input_stream, [], fn line, acc ->
      [_, data_part] = String.split(line, ":")
      all_numbers = data_part
                    |> String.split()
                    |> Enum.map(&String.trim/1)
                    |> Enum.map(&Integer.parse/1)
      winning_numbers = MapSet.new(all_numbers |> Enum.take_while(fn item -> match?({_, _}, item) end) |> Enum.map(fn {value, _} -> value end))
      numbers = all_numbers |> Enum.drop_while(fn item -> match?({_, _}, item) end) |> Enum.drop(1) |> Enum.map(fn {value, _} -> value end)
      [%Card{winning_numbers: winning_numbers, numbers: numbers} | acc]
    end)
  end

  defp calculate_card_score(card) do
    number_of_matches = Enum.reduce(card.numbers, 0, fn number, acc ->
      case MapSet.member?(card.winning_numbers, number) do
        false -> acc
        true -> acc + 1
      end
    end)
    case number_of_matches do
      0 -> 0
      x -> :math.pow(2, max(x - 1, 0))
    end
    |> trunc
  end

  def first_star(input_stream) do
    parse_cards(input_stream) |> Enum.reduce(0, fn card, acc -> acc + calculate_card_score(card) end)
  end
end
