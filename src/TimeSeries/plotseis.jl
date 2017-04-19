const μs = 1.0e-6
rescaled(x::Array{Float64,1},i::Int) = (Float64(i) + x./(2.0*maximum(abs(x))))

"""
plotseis(S)
Renormalized, time-aligned trace plot of data in S.x using timestamps in S.t.
plotseis(S, fmt=FMT)
Use format FMT to format x-labels. FMT is a standard C date format string.
plotseis(S, use_name=true)
Use channel names, instead of channel IDs, to label plot axes.
"""
function plotseis(S::SeisData; fmt="auto"::String, use_name=false::Bool, auto_x=true::Bool)
  # Basic plotting
  figure()
  axes([0.15, 0.1, 0.8, 0.8])
  xmi = 2^63-1
  xma = xmi+1
  yflag = false

  for i = 1:1:S.n
    t = SeisIO.t_expand(S.t[i], S.fs[i])
    xmi = min(xmi, t[1])
    xma = max(xmi, t[end])
    floor(t[1]*μs/31536000) == floor(t[end]*μs/31536000) || (yflag == true)
    if S.fs[i] > 0
      x = rescaled(S.x[i]-mean(S.x[i]),i)
      plot(t, x, linewidth=1)
    else
      x = (i-0.4) .+ 0.8*S.x[i]./maximum(S.x[i])
      for j = 1:length(t)
        plot([t[j], t[j]], [i-0.4, x[j]], color=[0, 0, 0], ls="-", lw=1)
      end
      plot(t, x, linewidth=1, marker="o", markeredgecolor=[0,0,0], ls="none")
    end
  end

  xfmt(xmi, xma, yflag, fmt=fmt, auto_x=auto_x)
  ylim(0.5, S.n+0.5)
  yticks(collect(1:1:S.n), map((i) -> replace(i, " ", ""), use_name? S.name : S.id))
  return nothing
end
