function uptimes_bar(S::SeisData, fmt::String, use_name::Bool, auto_x::Bool)
  xmi = 2^63-1
  xma = xmi+1
  yflag = false

  for i = 1:S.n
    t = SeisIO.t_expand(S.t[i],S.fs[i])
    xmi = min(xmi, t[1])
    xma = max(xma, t[end])
    floor(t[1]*μs/31536000) == floor(t[end]*μs/31536000) || (yflag == true)
    if S.fs[i] == 0
      plot(t, collect(repeated(i,length(t))),  marker="o", markeredgecolor=[0,0,0], markerfacecolor=[1,0,1], markersize=8, ls="none")
    else
      for j = 1:size(S.t[i],1)-1
        st = t[S.t[i][j,1]+1]
        en = t[S.t[i][j+1,1]-1]
        broken_barh([(st, en-st)], (i-0.4, 0.8), facecolor=[0,0,1])
      end
    end
  end

  xfmt(xmi, xma, yflag, fmt=fmt, auto_x=auto_x)
  ylim(0.5, S.n+0.5)
  yticks(collect(1:1:S.n), map((i) -> replace(i, " ", ""), use_name? S.name : S.id))
  title("Channel uptimes")
  return nothing
end

function uptimes_sum(S::SeisData, fmt::String, use_name::Bool, auto_x::Bool)
  xmi = 2^63-1
  xma = xmi+1
  yflag = false
  tt = Array{Int64,2}(0,2)

  for i = 1:S.n
    t = SeisIO.t_expand(S.t[i],S.fs[i])
    S.fs[i] == 0 && continue
    xmi = min(xmi, t[1])
    xma = max(xma, t[end])
    floor(t[1]*μs/31536000) == floor(t[end]*μs/31536000) || (yflag == true)
    for j = 1:size(S.t[i],1)-1
      st = t[S.t[i][j,1]+1]
      en = t[S.t[i][j+1,1]-1]
      tt = [tt; [st 1]; [en -1]]
    end
  end
  tt = sortrows(tt)
  t = tt[:,1]
  h = cumsum(tt[:,2])./S.n
  w = diff(t)
  x = t[1:end-1]
  bar(x,h[1:end-1],w,color="b")

  xfmt(xmi, xma, yflag, fmt=fmt, auto_x=auto_x)
  ylabel(@sprintf("%% of Network Active (n=%i)", sum(S.fs.>0)))
  ylim(0.0, 1.0)
  yticks(collect(0.0:0.2:1.0))
  return nothing
end

"""
plot_uptimes(S)
Bar plot of uptimes for each channel in S.
plot_uptimes(S, mode='b')
Bar plot of network uptime for all channels that record timeseries data, scaled
so that y=1 corresponds to all sensors active. Non-timeseries data in S are not
counted.
"""
function plot_uptimes(S::SeisData; mode='c'::Char, fmt="auto"::String, use_name=false::Bool, auto_x=true::Bool)
  figure()
  ax = axes([0.15, 0.1, 0.8, 0.8])

  if mode == 'c'
    uptimes_bar(S, fmt, use_name, auto_x)
  elseif mode == 'b'
    uptimes_sum(S, fmt, use_name, auto_x)
  end
  return nothing
end
