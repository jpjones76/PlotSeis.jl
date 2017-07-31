"""
    setax(ax::PyObject)

Set properties of axis `ax` using shorter commands.
"""

function setax(ax::PyCall.PyObject;
               Ts=""::String, ys=""::String, xs=""::String,
               xl::Array{Float64,1}=Float64[],
               yl::Array{Float64,1}=Float64[],
               xtl=true::Bool, ytl=true::Bool,
               cl=Float64[]::Array{Float64,1}, cb=false::Bool, cbl=""::String, cf=0.06::Float64, cp=0.02::Float64, ct=Float64[]::Array{Float64,1}
               )
  axes(ax)
  PyPlot.setp(ax[:get_yticklabels](),fontsize=10,color="black",fontweight="bold", family="serif")
  PyPlot.setp(ax[:get_xticklabels](),fontsize=10,color="black",fontweight="bold", family="serif")
  PyPlot.setp(ax[:tick_params]("both", width=2, labelsize=12))
  isempty(Ts) || PyPlot.title(Ts)
  isempty(xs) || PyPlot.xlabel(xs)
  isempty(ys) || PyPlot.ylabel(ys)
  isempty(xl) || PyPlot.xlim(xl)
  isempty(yl) || PyPlot.ylim(yl)
  xtl || (ax[:xaxis])[:set_ticklabels]([])
  ytl || (ax[:yaxis])[:set_ticklabels]([])
  isempty(cl) || clim(cl)
  if cb
    cbar = colorbar(label=cbl, use_gridspec=false, fraction=cf, pad=cp)
    if !isempty(ct)
      (cbar[:set_ticks])(ct)
    end
  end
end
