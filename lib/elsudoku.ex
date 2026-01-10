defmodule ElSudoku do

  alias InPlace.Examples.Sudoku, as: DLXSudoku
  @numbers ?1..?9

  def solve(instance, solver) when is_binary(instance) and is_function(solver, 1) do
    if valid_instance?(instance) do
      solver.(instance)
      |> tap(fn solutions ->
        Enum.each(solutions, &check_solution/1) end)
    else
      throw({:invalid_instance, instance})
    end
  end

  def valid_instance?(instance) do
    String.length(instance) == 81
  end

  def check_solution(solution) when is_binary(solution) do
    solution
    |> string_grid_to_list()
    |> check_solution()
  end

  def check_solution(solution) when is_list(solution) do
    DLXSudoku.check_solution(solution)
  end

  @doc """
    Solve with DLX (Knuth, Exact Cover)
  """
  def dlx_solver() do
    fn puzzle ->
      handler = fn s -> send(self(), s) end
      InPlace.Examples.Sudoku.solve(puzzle, solution_handler: handler)
      receive do
        msg -> [Enum.join(msg, "")]
      end
    end
  end

  def string_grid_to_list(str) do
    for <<cell <- str>> do
      if cell in @numbers do
        cell - 48
      else
        0
      end
    end
  end
end
