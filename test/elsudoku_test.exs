defmodule ElSudokuTest do
  use ExUnit.Case
  doctest ElSudoku

  test "run the instance (with DLX Sudoku)" do
    puzzle = "12.3.....4.....3....3.5......42..5......8...9.6...5.7...15..2......9..6......7..8"
    # solver = fn instance ->
    #   handler = fn s -> send(self(), s) end
    #   InPlace.Examples.Sudoku.solve(instance, solution_handler: handler)
    #   receive do
    #     msg -> [Enum.join(msg, "")]
    #   end
    # end
    assert hd(ElSudoku.solve(puzzle, ElSudoku.dlx_solver())) ==
             "125374896479618325683952714714269583532781649968435172891546237257893461346127958"
  end
end
