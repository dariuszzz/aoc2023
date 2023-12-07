defmodule Mix.Tasks.Aoc7 do
  use Mix.Task

  def run(_) do
    path = elem(File.cwd, 1) <> "/inputs/input7.txt"
    file = File.stream!(path)

    {p1time, p1} = :timer.tc(&solution/2, [file, &parse_hand1/1])
    IO.puts "Part 1: #{p1} - took #{p1time/1000}ms"
    {p2time, p2} = :timer.tc(&solution/2, [file, &parse_hand2/1])
    IO.puts "Part 2: #{p2} - took #{p2time/1000}ms"
  end

  def solution(filestream, parse_hand) do
    filestream
      |> Enum.map(&String.split(&1, " "))
      |> Enum.map(fn [hand, bid] -> [parse_hand.(String.trim(hand)), String.to_integer(String.trim(bid))] end)
      |> Enum.reduce([], fn [{type, hand}, bid], ranked_cards ->
        rank = ranked_cards
          |> Enum.reduce(0, fn [{cmp_type, cmp_hand}, cmp_bid], rank ->
            case {type, cmp_type} do
              {_, _} when type > cmp_type -> rank + 1
              {_, _} when type < cmp_type -> rank
              {_, _} when type == cmp_type ->
                hand
                  |> Enum.zip(cmp_hand)
                  |> Enum.reduce_while(rank, fn {card, cmp_card}, acc ->
                    case {card, cmp_card} do
                      {_, _} when card > cmp_card -> {:halt, acc + 1}
                      {_, _} when card < cmp_card -> {:halt, acc}
                      {_, _} when card == cmp_card -> {:cont, acc}
                    end
                  end)
            end
          end)

        List.insert_at(ranked_cards, rank, [{type, hand}, bid])
      end)
      |> Enum.with_index()
      |> Enum.reduce(0, fn {[{type, hand}, bid], rank}, acc ->
        acc + (rank + 1) * bid
      end)
  end

  def parse_hand2(hand) do
    parse_hand = fn hand ->
      hand
        |> String.codepoints()
        |> Enum.map(fn char ->
          case char do
            "A" -> 14
            "K" -> 13
            "Q" -> 12
            "J" -> 1
            "T" -> 10
            x -> String.to_integer(x)
          end
        end)
    end

    original_hand = parse_hand.(hand)
    cards = String.codepoints(hand)

    possible_hands = case {cards, "J" in cards} do
      {["J", "J", "J", "J", "J"], _}-> [original_hand]
      {_, false} -> [original_hand]
      _ ->
        hand
          |> String.codepoints()
          |> Enum.reject(fn char -> char == "J" end)
          |> Enum.map(fn char ->
            new_hand = hand
              |> String.replace("J", char)

            parse_hand.(new_hand)
          end)
    end

    type = possible_hands
      |> Enum.map(fn hand -> get_hand_type(hand) end)
      |> Enum.max

    {type, original_hand}
  end

  def parse_hand1(hand) do
    parsed_hand = hand
      |> String.codepoints()
      |> Enum.map(fn char ->
        case char do
          "A" -> 14
          "K" -> 13
          "Q" -> 12
          "J" -> 11
          "T" -> 10
          x -> String.to_integer(x)
        end
      end)

    type = get_hand_type(parsed_hand)

    {type, parsed_hand}
  end

  def get_hand_type(parsed_hand) do
    highest_duplicate_counts = parsed_hand
      |> Enum.frequencies()
      |> Map.values()
      |> Enum.sort()
      |> Enum.reverse()

    case highest_duplicate_counts do
      [5 | _] -> 6
      [4 | _] -> 5
      [3, 2 | _] -> 4
      [3 | _] -> 3
      [2, 2 | _] -> 2
      [2 | _] -> 1
      [1, 1, 1, 1, 1] -> 0
    end
  end
end
