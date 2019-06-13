__precompile__()
module PlotSeis
using Printf, SeisIO, PyPlot
using Statistics: mean
using DSP: spectrogram, time, freq, power
import SeisIO: t_expand, μs, t_win
export plotseis,
       uptimes,
       logspec

# Time series plots
include("TimeSeries/ts_internals.jl")
include("TimeSeries/plotseis.jl")

# Spectral plots
include("Spectral/logspec.jl")

# Other plots
include("Other/uptimes.jl")

end
