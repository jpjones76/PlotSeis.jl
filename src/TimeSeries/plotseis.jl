"""
    plotseis(S[, fmt=FMT, use_name=false, n=N])

Renormalized, time-aligned trace plot of data in S.x using timestamps in S.t.

Keywords:
* fmt=FMT formats x-axis labels using C-language `strftime` format string `FMT`.
If unspecified, the format is determined by when data in `S` start and end.
* use_name=true uses `S.name`, rather than `S.id`, for labels.
* n=N sets the number of X-axis ticks.

"""
function plotseis(S::SeisData; fmt::String="auto", use_name::Bool=false, nxt::Int64=5)
  xmi = typemax(Int64)
  xma = typemin(Int64)

  fig = PyPlot.figure(figsize=[8.0, 6.0], dpi=150)
  ax = PyPlot.axes([0.20, 0.10, 0.72, 0.85])
  for i = 1:S.n
    x = rescaled(S.x[i].-mean(S.x[i]),i)
    if S.fs[i] > 0
      t = t_expand(S.t[i], S.fs[i])
      plot(t, x, linewidth=1.0)
    else
      t = view(S.t[i], :, 2)
      plot(t, x, "o", linewidth=1, markeredgecolor=[0,0,0])
    end
    xmi = min(xmi, t[1])
    xma = max(xma, t[end])
  end

  xfmt(xmi, xma, fmt, nxt)
  PyPlot.setp(gca().get_yticklabels(), fontsize=8.0, color="black", fontweight="bold", family="serif")
  PyPlot.setp(gca().get_xticklabels(), fontsize=8.0, color="black", fontweight="bold", family="serif")
  PyPlot.yticks(1:S.n, map((i) -> replace(i, " " => ""), use_name ? S.name : S.id))
  PyPlot.ylim(0.5, S.n+0.5)
  return fig
end
