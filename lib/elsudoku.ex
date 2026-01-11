defmodule ElSudoku do
  alias InPlace.Examples.Sudoku, as: DLXSudoku
  @numbers ?1..?9

  def puzzle_sets() do
    %{
      clue17: "clue17",
      top95: "top95",
      hardest: "hardest",
      quasi_uniform: "quasi_uniform_834",
      puzzles5_forum_hardest: "puzzles5_forum_hardest_1905_11+",
      misc: "misc"
    }
  end
  def solve(instance, solver) when is_binary(instance) and is_function(solver, 1) do
    if valid_instance?(instance) do
      solver.(instance)
      |> tap(fn solutions ->
        Enum.each(solutions, &check_solution/1)
      end)
    else
      throw({:invalid_instance, instance})
    end
  end

  def benchmark(puzzle_file, solver, opts \\ []) when is_binary(puzzle_file) do
    num_instances = Keyword.get(opts, :num_instances)

    puzzles =
      File.read!(Path.join("/Users/bokner/projects/fixpoint", puzzle_file))
      |> String.split("\n")
      |> Enum.map(fn str -> String.slice(str, 0..80) end)
      |> then(fn list -> num_instances && Enum.take(list, num_instances) || list end)

    res =
      Enum.map(Enum.with_index(puzzles, 1), fn {p, idx} ->
        {tc, _} =
          :timer.tc(fn ->
            {:solved, _, _board} = Sudoku.solve(p)
          end)
          |> tap(fn {tc, _idx} -> IO.puts("#{idx} : #{round(tc / 1000)} ms") end)

        {tc, idx}
      end)

    times = Enum.map(res, fn {time, _idx} -> time end) |> Enum.sort()

    stats = %{
      shortest: Enum.min(times),
      longest: Enum.max(times),
      average: Enum.sum(times) / length(times),
      total: Enum.sum(times),
      sorted: Enum.sort(times),
      median: Enum.at(times, div(length(times), 2))
    }
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
