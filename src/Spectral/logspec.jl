function logspec(S::SeisData, k::Union{Int64,String};
  nx::Int64=1024,
  ov::Float64=0.5,
  fmin::Real=0.0,
  fmax::Real=Inf,
  fmt::String="auto")

  N_ticks = 5

  if isa(k, String)
    j = findid(k, S)
    j == 0 && error("No matching ID or no channel at the specified #")
  else
    j = k
  end

  seis = deepcopy(S[j])
  T = eltype(seis.x)
  unscale!(seis)
  demean!(seis)
  taper!(seis)
  tos = seis.t[1,2]
  fs = T(seis.fs)

  # Set some image properties
  sz = Float64[8.0, 5.0]                              # Size of image in inches
  cf = 0.05                                           # Colorbar fraction
  cp = 0.02                                           # Colorbar spacing
  x0 = 0.14
  y0 = 0.12
  tsh = 0.13
  wid = 0.90-x0
  sp = (x0, y0+tsh+cp, wid, 0.98-(y0+tsh+cp))         # Spectrogram plot bounds
  tp = (x0, y0, wid*(1.0-(cf+cp)), tsh)               # Timeseries plot bounds
  fmax = T(min(fmax, 0.5*fs))                         # Maximum frequency to plot

  # Generate spectrogram
  if fmin != 0.0
    nx = nextpow(2, 4.0/fmin)
  end
  no = floor(Int64, ov*nx)
  sg = spectrogram(seis.x, nx, no, fs=fs)
  t = Int64.(round.(time(sg).*1.0e6)) .+ tos          # Time from start (s)
  f = T.(collect(freq(sg)))                           # Frequency (Hz)
  P = T(10.0)*log10.(power(sg))                       # Power (dB)

  # x ticks
  xti = first(t) : div(last(t) - first(t), N_ticks-1) : last(t)
  xtl = fill!(Array{String,1}(undef, length(xti)), "")

  # truncate P, y
  i0 = max(2, findfirst(f.≥max(0.5*fs/nx, fmin)))     # First sane frequency index
  i1 = findlast(f.≤fmax)                              # Last sane frequency index
  P = P[i0:i1, :]
  y = log10.(f)[i0:i1]

  # Remove all -∞
  mP = maximum(P)
  pτ = mP - T(60.0) - eps(T)
  P[P.<pτ] .= pτ

  # y ticks
  f0 = log10(f[i0])                                   # Minimum frequency to show
  f1 = log10(f[i1])                                   # Maximum frequency to show
  yt = collect(ceil(f0) : 0.5 : floor(f1))
  yti = T(10.0) .^ vcat(f0, yt, f1)
  if fmin < 0.1
    ytl = vcat("", [@sprintf("%0.1e", T(10.0)^i) for i in yt], "")
  else
    ytl = vcat("", [@sprintf("%0.1f", T(10.0)^i) for i in yt], "")
  end

  # Figure
  h = PyPlot.figure(figsize = sz, dpi=150)

  # Seismogram plot
  ax_ts = PyPlot.axes(tp)
  dt    = one(T)/fs
  tx    = t_expand(seis.t, seis.fs)
  xmax  = 1.0*maximum(abs.(seis.x))
  ts_xl = @sprintf("%0.2e", xmax)
  PyPlot.plot(tx, seis.x, linewidth=1.0, color="k")
  PyPlot.ylim(xmax .*(T(-1.05), T(1.05)))
  xfmt(round(Int64, first(xti)), round(Int64, last(xti)), fmt, N_ticks)
  PyPlot.xlabel(ax_ts.get_xlabel(), fontsize=12.0, color="black", fontweight="bold", family="serif")
  PyPlot.yticks([-xmax, zero(T), xmax], ["-"*ts_xl, "0.00e00", "+"*ts_xl])
  PyPlot.setp(ax_ts.get_yticklabels(), fontsize=9.0, color="black", fontweight="bold", family="serif")
  PyPlot.setp(ax_ts.get_xticklabels(), fontsize=9.0, color="black", fontweight="bold", family="serif")

  # Note: imshow won't work with unevenly-spaced y-ticks
  ax_sp = PyPlot.axes(sp)
  img = pcolormesh(t, y, P, cmap="Spectral_r", shading="goraud")
  PyPlot.ylabel("Frequency [Hz]", fontweight="bold", fontsize=12.0, family="serif", color="black")
  PyPlot.ylim(f0, f1)
  PyPlot.yticks(log10.(yti), ytl)
  PyPlot.setp(ax_sp.get_yticklabels(), fontsize=9.0, color="black", fontweight="bold", family="serif")
  PyPlot.xlim(minimum(t), maximum(t))
  PyPlot.xticks(xti, xtl)

  # Set color limits and draw colorbar
  cl = [mP-60.0, mP]
  PyPlot.clim(cl)
  cb = PyPlot.colorbar(label="Power [dB]", use_gridspec=false, fraction=cf, pad=cp)
  PyPlot.setp(cb.ax.get_yticklabels(), fontsize=9.0, color="black", fontweight="bold", family="serif")
  cb.set_label("Power [dB]", fontsize=10.0, color="black", fontweight="bold", family="serif")
  return h
end
