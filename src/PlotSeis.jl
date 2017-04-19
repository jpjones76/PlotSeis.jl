# VERSION >= v"0.4.0" && __precompile__(true)
module PlotSeis
using SeisIO, DSP, PyPlot, PyCall
export plotseis,
       plot_uptimes,
       logspec

# Time series plots
include("TimeSeries/ts_internals.jl")
include("TimeSeries/plotseis.jl")

# Spectral plots
include("Spectral/logspec.jl")

# Other plots
include("Other/uptimes.jl")

end
