defmodule Day04 do
  defmodule Card do
    defstruct id: 0, winning_numbers: MapSet.new([]), numbers: []
  end

  defp parse_cards(input_stream) do
    Enum.reduce(input_stream, [], fn line, acc ->
      [id_part, data_part] = String.split(line, ":")
      all_numbers = data_part
                    |> String.split()
                    |> Enum.map(&String.trim/1)
                    |> Enum.map(&Integer.parse/1)
      winning_numbers = MapSet.new(all_numbers |> Enum.take_while(fn item -> match?({_, _}, item) end) |> Enum.map(fn {value, _} -> value end))
      numbers = all_numbers |> Enum.drop_while(fn item -> match?({_, _}, item) end) |> Enum.drop(1) |> Enum.map(fn {value, _} -> value end)
      [_, id_string] = id_part |> String.split()
      [%Card{id: Integer.parse(id_string) |> elem(0), winning_numbers: winning_numbers, numbers: numbers} | acc]
    end)
  end

  def calculate_number_of_matches(card) do
    Enum.reduce(card.numbers, 0, fn number, acc ->
      case MapSet.member?(card.winning_numbers, number) do
        false -> acc
        true -> acc + 1
      end
    end)
  end

  defp calculate_card_score(card) do
    case calculate_number_of_matches(card) do
      0 -> 0
      x -> :math.pow(2, max(x - 1, 0))
    end
    |> trunc
  end

  def first_star(input_stream) do
    parse_cards(input_stream) |> Enum.reduce(0, fn card, acc -> acc + calculate_card_score(card) end)
  end

  defp process_card_batch(cards, num_processed, original_cards) do
    new_batch = cards |> Enum.reduce([], fn card, acc ->
      number_of_matches = calculate_number_of_matches(card)
      # With zero matches, we don't want any iteration of the loop.
      new_batch_per_card = for card_id <- (card.id + 1)..(card.id + number_of_matches)//1 do
        Map.fetch!(original_cards, card_id)
      end
      new_batch_per_card ++ acc
    end)

    case length(new_batch) do
      0 -> num_processed + length(cards)
      _ -> num_processed + process_card_batch(new_batch, length(cards), original_cards)
    end
  end

  def second_star(input_stream) do
    original_cards = parse_cards(input_stream)
    process_card_batch(original_cards, 0, original_cards |> Map.new(fn card -> {card.id, card} end))
  end
end
