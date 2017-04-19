using PyCall, PyPlot, SeisIO
@pyimport matplotlib.mlab as mlab

function logspec(S::SeisData, k::Union{Int,String}, nx::Int, no::Int;
  fmin=0.1::Float64, fmax=Inf::Float64, r=80::Real, pm=(-Inf)::Real, xlfmt="mm-ddTHH:MM"::String)

  j = isa(k, String) ? findfirst(S.id[i].==k) : k
  j == 0 && error("No matching ID or no channel at the specified #")

  seis = S[j]
  ungap!(seis)
  x = (seis.x .- mean(seis.x)).*(1.0/seis.gain)
  tos = seis.t[1,2]/1.0e6
  fs = seis.fs

  # Set some image properties
  sz = Float64[12.0, 10.0]                            # Size of image in inches
  cf = 0.06                                           # Colorbar fraction
  cp = 0.02                                           # Colorbar spacing
  sp = [0.075, 0.225, 0.86, 0.70]                     # Spectrogram plot bounds
  tp = [0.075, 0.075, 0.86*(1.0-(cf+cp)), 0.13]       # Timeseries plot bounds
  pr = r/2.0                                          # Extent of colors from middle
  fmax = min(fmax, 0.45*fs)                           # Maximum frequency to plot

  # Generate spectrogram
  sp = spectrogram(x, nx, no, fs=fs)
  t = collect(time(sp))                               # Time from start (s)
  f = collect(freq(sp))                               # Frequency (Hz)
  P = 10.*log10(power(sp))                            # Power (dB)

  # Remove all vals of -∞
  P0 = minimum(P[!isinf(P)])
  P[P.<P0] = P0

  # Set some indices and future labels
  i0 = max(2, findfirst(f.≥max(2*fs/nx, fmin)))       # First sane frequency index
  i1 = findlast(f.≤fmax)                              # Last sane frequency index
  f0 = f[i0]                                          # Minimum frequency to show
  f1 = f[i1]                                          # Maximum frequency to show
  xti = first(t) : (last(t) - first(t))/5 : last(t)   # xtick spacing

  # Create figure and axes with logarithmic y scaling
  h = figure(figsize = sz)
  ax_sp = axes(sp)
  ax_sp[:set_yscale]("log")

  # NOTES ON COMMANDS BELOW
  # (1) imshow currently won't work with log scaling; maybe version-related (newer matplotlib allegedly does this)
  # (2) setting clim in "pcolormesh" won't work; this might be a keyword that the Julia port doesn't implement correctly

  # Generate the spectrogram using pcolormesh
  img = pcolormesh(t, f, P)

  # Set color limits and draw colorbar
  mP = isfinite(pm) ? pm : mean(P)
  cl = [mP-pr, mP+pr]
  clim(cl)
  cb = colorbar(label="Power [dB]", use_gridspec=false, fraction=cf, pad=cp)

  # Axis properties
  PyPlot.setp(ax_sp[:get_yticklabels](),fontsize=10,color="black",fontweight="bold", family="serif")
  PyPlot.xticks(xti, String[], rotation=0, fontsize=10,color="black",fontweight="bold", family="serif")
  PyPlot.ylabel("Frequency [Hz]", fontweight="bold", fontsize=12, family="serif", color="black")
  PyPlot.setp(ax_sp[:tick_params]("both", width=2, labelsize=10))
  PyPlot.xlim([minimum(t), maximum(t)])
  PyPlot.ylim([f0, f1])

  # Plot seismogram
  ax_ts = axes(tp)
  dt = 1.0/fs
  tx = (dt.*collect(1:1:length(x)))
  plot(tx, x, "k-", linewidth=0.25)

  # Set x-labels to true times
  xtl = Array{String,1}(length(xti))
  if xlfmt == "mm-ddTHH:MM"
    for (i,l) in enumerate(xti)
      dt = Dates.unix2datetime(l+tos)
      xtl[i] = string(join([@sprintf("%02i", Dates.Month(dt).value),
                            @sprintf("%02i", Dates.Day(dt).value)], '-'),
                            "T",
                            join([@sprintf("%02i", Dates.Hour(dt).value),
                                  @sprintf("%02i", Dates.Minute(dt).value)], ':')
                      )
    end
    PyPlot.xticks(xti, xtl, rotation=0, fontsize=10,color="black",fontweight="bold", family="serif")
    PyPlot.xlabel("Time [mm-ddThh:mm]", fontweight="bold", fontsize=12, family="serif", color="black")
  else
    PyPlot.xlabel("Time [s]", fontweight="bold", fontsize=12, family="serif", color="black")
  end

  # Axis properties
  PyPlot.setp(ax_ts[:tick_params]("both", width=2, labelsize=10))
  PyPlot.xlim([minimum(t), maximum(t)])
  return (ax_sp, ax_ts)
end
