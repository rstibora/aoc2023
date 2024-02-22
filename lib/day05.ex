defmodule Day05 do
  defmodule Range do
    defstruct destination_start: 0, source_start: 0, length: 0
  end

  defmodule Mapping do
    defstruct name: "", ranges: []
  end

  defp parseMapping(input_lines_section) do
    [name_section | mappings_section] = input_lines_section
    ranges = for range <- mappings_section do
      [destination_start_string | [source_start_string | [length_string | []]]] = String.split(range)
      %Range{
        destination_start: Integer.parse(destination_start_string) |> elem(0),
        source_start: Integer.parse(source_start_string) |> elem(0),
        length: Integer.parse(length_string) |> elem(0)
      }
    end
    %Mapping{name: hd(String.split(name_section)), ranges: ranges}
  end

  defp parse_input(input_stream) do
    chunk_fun = fn element, acc ->
      if element == "\n" do
        {:cont, Enum.reverse(acc), []}
      else
        {:cont, [element | acc]}
      end
    end

    after_fun = fn
      [] -> {:cont, []}
      acc -> {:cont, Enum.reverse(acc), []}
    end

    [seeds_string | ["\n" | rest_of_input]] = input_stream |> Enum.to_list
    seeds = Enum.reduce(seeds_string |> String.split |> tl, [], fn element, acc -> [Integer.parse(element) |> elem(0)| acc] end)
    mappings = Enum.chunk_while(rest_of_input, [], chunk_fun, after_fun) |> Enum.map(&parseMapping/1)
    {seeds, mappings}
  end

  defp process_seed_by_ranges(seed, []) do
    seed
  end

  defp process_seed_by_ranges(seed, ranges) do
    [range | rest_of_ranges] = ranges
    cond do
      seed < range.source_start or seed >= range.source_start + range.length ->
        process_seed_by_ranges(seed, rest_of_ranges)
      true ->
        seed + range.destination_start - range.source_start
    end
  end

  def process_seed(seed, mappings) do
    mappings |> Enum.reduce(seed, fn mapping, acc ->
      process_seed_by_ranges(acc, mapping.ranges) end)
  end

  def first_start(input_stream) do
    {seeds, mappings} = parse_input(input_stream)
    seeds |> Enum.map(fn seed -> process_seed(seed, mappings) end)
          |> Enum.reduce(fn item, acc -> min(item, acc) end)
  end
end
