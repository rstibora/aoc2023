defmodule Day03 do
  defmodule EngineSchematic do
    defstruct data: %{}, x_size: 0, y_size: 0
  end

  defp parse_engine_schematic(input_stream) do
    data = input_stream
    |> Enum.with_index
    |> Enum.reduce(%{}, fn {line, line_index}, acc ->
      line
      |> String.trim
      |> String.graphemes
      |> Enum.with_index
      |> Enum.reduce(acc, fn {char, char_index}, line_acc -> Map.put_new(line_acc, {char_index, line_index}, char) end)
    end)

    data = for {key, string_value} <- data, reduce: %{} do
      acc ->
        value = case Integer.parse(string_value) do
          {_, _} -> {:number, string_value}
          :error -> case string_value do
            "." -> :space
            char -> {:symbol, char}
          end
        end
        Map.put(acc, key, value)
    end

    %EngineSchematic{data: data,
                     x_size: Enum.reduce(Map.keys(data), 0, fn {x, _}, acc -> max(acc, x) end) + 1,
                     y_size: Enum.reduce(Map.keys(data), 0, fn {_, y}, acc -> max(acc, y) end) + 1}
  end

  defp find_part_numbers(engine_schematic) do
    # Accumulated to a map of {line, ends}: starts.
    for y <- 0..engine_schematic.y_size - 1, reduce: %{} do
      acc -> for x <- 0..engine_schematic.x_size - 1, reduce: acc do
        acc -> case Map.fetch!(engine_schematic.data, {x, y}) do
                {:number, _} ->
                  case Map.fetch(acc, {y, x - 1}) do
                    {:ok, starts_at} -> acc |> Map.drop([{y, x - 1}]) |> Map.put({y, x}, starts_at)
                    :error -> acc |> Map.put({y, x}, x)
                  end
                _ -> acc
              end
        end
    end
  end

  defp find_numbers_for_gears(engine_schematic, part_numbers) do
    for {{line, ends}, starts} <- part_numbers, reduce: %{} do
      numbers_per_gear ->
        number = number_string_to_int(line, starts, ends, engine_schematic)
        numbers_per_gear = for y <- [line - 1, line + 1], reduce: numbers_per_gear do
          numbers_per_gear -> for x <- starts - 1..ends + 1, reduce: numbers_per_gear do
            numbers_per_gear -> case Map.fetch(engine_schematic.data, {x, y}) do
                                  {:ok, {:symbol, "*"}} -> Map.update(numbers_per_gear, {x, y}, [number], fn numbers -> [number | numbers] end)
                                  _ -> numbers_per_gear
            end
          end
        end
        numbers_per_gear = case Map.fetch(engine_schematic.data, {starts - 1, line}) do
          {:ok, {:symbol, "*"}} -> Map.update(numbers_per_gear, {starts - 1, line}, [number], fn numbers -> [number | numbers] end)
          _ -> numbers_per_gear
        end
        case Map.fetch(engine_schematic.data, {ends + 1, line}) do
          {:ok, {:symbol, "*"}} -> Map.update(numbers_per_gear, {ends + 1, line}, [number], fn numbers -> [number_string_to_int(line, starts, ends, engine_schematic) | numbers] end)
          _ -> numbers_per_gear
        end
    end
  end

  defp symbol_nearby?(starts, ends, line, engine_schematic) do
    # Check one line above and one below...
    for y <- [line - 1, line + 1], reduce: false do
      has_symbol -> for x <- starts - 1..ends + 1, reduce: has_symbol do
        has_symbol -> has_symbol or match?({:ok, {:symbol, _}}, Map.fetch(engine_schematic.data, {x, y}))
      end
    end
    # ... and the two sides on the same line.
    or match?({:ok, {:symbol, _}}, Map.fetch(engine_schematic.data, {starts - 1, line}))
    or match?({:ok, {:symbol, _}}, Map.fetch(engine_schematic.data, {ends + 1, line}))
  end

  defp sum_part_numbers_near_symbols(part_numbers, engine_schematic) do
    Enum.reduce(part_numbers, 0,
      fn {{line, ends}, starts}, sum ->
        sum + if symbol_nearby?(starts, ends, line, engine_schematic), do: number_string_to_int(line, starts, ends, engine_schematic), else: 0
      end)
  end

  defp number_string_to_int(line, starts, ends, engine_schematic) do
    digits = for x <- starts..ends, reduce: "" do
      acc -> {:number, digit} = Map.fetch!(engine_schematic.data, {x, line})
              acc <> digit
    end
    with {number, _} <- Integer.parse(digits), do: number
  end

  def first_star(input_stream) do
    engine_schematic = input_stream |> parse_engine_schematic
    part_numbers = engine_schematic |> find_part_numbers
    sum_part_numbers_near_symbols(part_numbers, engine_schematic)
  end

  def second_star(input_stream) do
    engine_schematic = input_stream |> parse_engine_schematic
    part_numbers = engine_schematic |> find_part_numbers
    numbers_for_gears = find_numbers_for_gears(engine_schematic, part_numbers)
    numbers_for_gears |> Enum.reduce(0, fn {{_, _}, numbers}, acc ->
        case length(numbers) do
          2 ->
            [a, b] = numbers
            acc + (a * b)
          _ -> acc
        end
      end)
  end
end
