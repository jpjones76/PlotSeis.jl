function uptimes_bar(S::SeisData, fmt::String, use_name::Bool, nxt::Int64)
  xmi = 2^63-1
  xma = xmi+1
  fig = PyPlot.figure(figsize=[8.0, 6.0], dpi=150)
  ax = PyPlot.axes([0.20, 0.10, 0.72, 0.85])

  for i = 1:S.n
    if S.fs[i] == 0.0
      t = view(S.t[i], :, 2)
      x = rescaled(S.x[i].-mean(S.x[i]),i)
      plot(t, x, "ko", markersize = 2.0)
    else
      rect_x = Array{Float64,1}(undef, 0)
      rect_y = Array{Float64,1}(undef, 0)
      t = t_win(S.t[i], S.fs[i])
      for j = 1:size(t,1)
        ts = Float64(t[j,1])
        te = Float64(t[j,2])
        append!(rect_x, [ts, te, te, ts, ts])
        append!(rect_y, [i-0.48, i-0.48, i+0.48, i+0.48, i-0.48])
      end

      p = fill(rect_x, rect_y, linewidth=1.0, edgecolor="k")
    end
    xmi = min(xmi, first(t))
    xma = max(xma, last(t))
  end

  PyPlot.title("Channel Uptimes", fontweight="bold", fontsize=13.0, family="serif", color="black")

  # Y scaling and axis manipulation
  PyPlot.yticks(1:S.n, map((i) -> replace(i, " " => ""), use_name ? S.name : S.id))
  PyPlot.ylim(0.5, S.n+0.5)
  PyPlot.setp(gca().get_yticklabels(), fontsize=8.0, color="black", fontweight="bold", family="serif")

  # X scaling and axis manipulation
  xfmt(xmi, xma, fmt, nxt)
  PyPlot.setp(gca().get_xticklabels(), fontsize=10.0, color="black", fontweight="bold", family="serif")

  return fig
end

function uptimes_sum(S::SeisData, fmt::String, use_name::Bool, nxt::Int64)
  ntr = sum(S.fs.>0)
  W = Array{Int64, 1}(undef, 0)
  for i = 1:S.n
    S.fs[i] == 0.0 && continue
    w = div.(t_win(S.t[i], S.fs[i]), 1000000)
    for i = 1:size(w,1)
      append!(W, collect(w[i,1]:w[i,2]))
    end
  end
  sort!(W)
  t = collect(first(W):last(W))
  y = zeros(Int64, length(t))
  i = 0
  j = 1
  τ = first(t)
  while i < length(W)
    i = i + 1
    if W[i] == τ
      y[j] += 1
    else
      while W[i] != τ
        j += 1
        j > length(t) && break
        τ = t[j]
      end
      y[j] += 1
    end
  end
  fig = PyPlot.figure(figsize=[8.0, 6.0], dpi=150)
  step(t.*1000000, y, color="k", linewidth=2.0)

  # Y scaling and axis manipulation
  dy = ntr > 24 ? 5.0 : ntr > 19 ? 4.0 : ntr > 14 ? 3.0 : ntr > 9 ? 2.0 : 1.0
  PyPlot.ylim(0, ntr)
  PyPlot.yticks(ntr:-dy:0)
  PyPlot.ylabel("Active Channels", fontweight="bold", fontsize=12.0, family="serif", color="black")
  PyPlot.setp(gca().get_yticklabels(), fontsize=10.0, color="black", fontweight="bold", family="serif")

  # X scaling and axis manipulation
  xfmt(first(t)*1000000, last(t)*1000000, fmt, nxt)
  PyPlot.setp(gca().get_xticklabels(), fontsize=10.0, color="black", fontweight="bold", family="serif")
  return fig
end

"""
    uptimes(S[, summed=false])

Bar plot of uptimes for each channel in S.

If summed==true, plot uptimes for all channels in S that record timeseries data,
scaled so that y=1 corresponds to 100% of channels active. Non-timeseries
channels in S are not counted toward the cumulative total in a summed uptime plot.
"""
function uptimes(S::SeisData; summed::Bool=false, fmt::String="auto", use_name::Bool=false, nxt::Int64=5)
  if summed
    fig = uptimes_sum(S, fmt, use_name, nxt)
  else
    fig = uptimes_bar(S, fmt, use_name, nxt)
  end
  return fig
end
