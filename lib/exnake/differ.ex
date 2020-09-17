defmodule Exnake.Differ do
  def encode(last, current) do
    String.myers_difference(last, current)
    |> Enum.map(fn {k, v} ->
      case k do
        :eq -> %{k => String.length(v)}
        :ins -> %{k => v}
        :del -> %{k => String.length(v)}
      end
    end)
    |> List.flatten()
  end

  def decode(last, encoded) do
    {_, result} =
      Enum.reduce(encoded, {0, ""}, fn {k, v}, {location, current} ->
        case k do
          :eq ->
            addition = String.slice(last, location, v)
            {location + v, current <> addition}

          :ins ->
            {location, current <> v}

          :del ->
            {location + v, current}
        end
        |> IO.inspect()
      end)

    result
  end

  # def test(last, current) do
  #   encoded = encode(last, current) |> IO.inspect
  #   IO.inspect(encoded == [eq: 1, del: 1, eq: 12, del: 4, eq: 1, del: 3])
  #   decoded = decode(last, encoded) |> IO.inspect
  #   IO.inspect(decoded == current)
  # end
end
