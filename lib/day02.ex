defmodule Day02 do
  @number_of_red 12
  @number_of_green 13
  @number_of_blue 14

  defmodule GameSubset do
    defstruct red: 0, green: 0, blue: 0
  end

  defp parse_game(input_line) do
    [game_identification_string, cube_subsets_string | _] = input_line |> String.trim() |> String.split(":", trim: true)

    [_, game_id_string | _] = String.split(game_identification_string, " ", trim: true)
    game_id = String.to_integer(game_id_string)

    game_subsets = String.split(cube_subsets_string, ";", trim: true) |> Enum.map(fn cube_subset_string ->
      String.split(cube_subset_string, ",", trim: true) |> Enum.reduce(%GameSubset{}, fn item, acc ->
        [amount_string, colour] = String.split(item, " ", trim: true)
        amount = String.to_integer(amount_string)
        case colour do
          "red" -> %{acc | red: amount}
          "green" -> %{acc | green: amount}
          "blue" -> %{acc | blue: amount}
        end
      end)
    end)

    {game_id, game_subsets}
  end

  defp game_subset_valid?(game_subset) do
    game_subset.red <= @number_of_red and game_subset.green <= @number_of_green and game_subset.blue <= @number_of_blue
  end

  defp game_round_power(game_subsets) do
    minimum_amounts = game_subsets
    |> Enum.reduce(%{}, fn game_subset, minimum_amounts ->
                          Map.merge(minimum_amounts, game_subset, fn _, amount_a, amount_b ->
                            max(amount_a, amount_b)
                          end)
                        end)
    minimum_amounts.red * minimum_amounts.green * minimum_amounts.blue
  end

  def first_star(input_stream) do
    input_stream |> Stream.map(fn line -> parse_game(line) end)
                 |> Enum.reduce(0,
                  fn game_round, game_ids_sum ->
                    {game_id, game_subsets} = game_round
                    round_valid = game_subsets |> Enum.reduce(true,
                      fn game_subset, is_valid_acc ->
                        is_valid_acc and game_subset_valid?(game_subset)
                      end)
                    case round_valid do
                      true -> game_ids_sum + game_id
                      false -> game_ids_sum
                    end
                  end)
  end

  def second_star(input_stream) do
    input_stream |> Stream.map(fn line -> parse_game(line) end)
                 |> Enum.reduce(0,
                 fn game_round, game_power_sum ->
                  {_, game_subsets} = game_round
                  game_power_sum + game_round_power(game_subsets)
                 end)
  end
end
