defmodule Exnake.Player.State do
  defstruct id: nil,
    name: "",
    dead: false,
    score: 0,
    body_position: [],
    head_position: nil,
    direction: :up,
    move_lock: false,
    food_eaten: false
end
