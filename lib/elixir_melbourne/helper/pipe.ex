defmodule ElixirMelbourne.Helper.Pipe do
  @moduledoc """
    PipeHelper - increase pipe function readability and make it cooler
    When you want to use this module, please use `use Gaia.Helper.Pipe`
  """

  def better_piping(value, call, i) do
    # to support recursive, need uniq binding name
    binding = Macro.var(:"$fb$#{i}", __MODULE__)

    {call, n} =
      Macro.prewalk(call, 0, fn
        {:__, _meta, ctx}, n when is_atom(ctx) -> {binding, n + 1}
        {:|>, _meta, [v, c]}, n -> {better_piping(v, c, i + 1), n}
        ast, n -> {ast, n}
      end)

    cond do
      n == 0 ->
        Macro.pipe(value, call, 0)

      n == 1 ->
        Macro.prewalk(call, fn
          ^binding -> value
          ast -> ast
        end)

      n ->
        quote do
          unquote(binding) = unquote(value)
          unquote(call)
        end
    end
  end

  defmacro left |> right do
    Helper.Pipe.better_piping(left, right, 0)
  end

  @doc """
    Overwrite Kernel to use this
  """
  defmacro __using__(_) do
    quote do
      import Kernel, except: [|>: 2]
      import unquote(__MODULE__), only: [|>: 2]
    end
  end
end
