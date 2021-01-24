defmodule TasksTracker.TaskStateMachine do
  use Machinery,
    # The first state declared will be considered the initial state.
    states: ["new", "assigned", "done"],
    transitions: %{
      "new" => "assigned",
      "assigned" => "done"
    }
end
