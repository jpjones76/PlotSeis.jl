rescaled(x::Array{Float32,1},i::Int) = Float32(i) .+ x.*(1.0f0/(2.0f0*maximum(abs.(x))))
rescaled(x::Array{Float64,1},i::Int) = Float64(i) .+ x.*(1.0/(2.0*maximum(abs.(x))))

# Formatted X labels
function xfmt(xmi::Int64, xma::Int64, fmt::String, N::Int64)
  dt = (xma-xmi)
  tzcorr = Libc.TmStruct(time())._11

  if fmt == "auto"
    # timespan < one minute
    x0 = div(xmi, 1000000)
    x1 = div(xma, 60000000)
    if x0 == x1
      fmt = "%S"
      xstr = string("Seconds from %s:00 [UTC]", Libc.strftime("%Y-%m-%d %H:%M", xmi*μs - tzcorr))
    else
      # timespan < one hour
      x0 = div(x0, 60)
      x1 = div(x1, 60)
      if x0 == x1
        fmt = "%M:%S"
        xstr = string("MM:SS from %s:00:00 [UTC]", Libc.strftime("%Y-%m-%d %H", xmi*μs - tzcorr))
      else
        # timespan < one day
        x0 = div(x0, 24)
        x1 = div(x1, 24)
        if x0 == x1
          fmt = "%H:%M:%S"
          xstr = string("Time [UTC], ", Libc.strftime("%Y-%m-%d", xmi*μs - tzcorr))
        else
          # timespan < one year
          if div(xmi, 31536000000000) == div(xma, 31536000000000)
            fmt = "%j, %T"
            xstr = string("JDN (", Libc.strftime("%Y", xmi*μs - tzcorr), "), Time [UTC]")
          else
            fmt ="%Y-%m-%d %H:%M:%S"
            xstr = string("DateTime [UTC]")
          end
        end
      end
    end
    # plot!(xlabel = xstr)
    PyPlot.xlabel(xstr,
    fontsize=12.0, color="black", fontweight="bold", family="serif")
  else
    # plot!(xlabel = string("Time [", replace(fmt, "%" => ""), "]"))
    PyPlot.xlabel(string("Time [", replace(fmt, "%" => ""), "]"),
    fontsize=12.0, color="black", fontweight="bold", family="serif")
  end

  dt = dt / (N-1)
  xt = Array{Float64,1}(undef, N)
  xl = Array{String,1}(undef, N)
  t = xmi
  for i = 1:N
    setindex!(xt, t, i)
    setindex!(xl, Libc.strftime(fmt, xt[i]*μs), i)
    t = t + dt
  end
  PyPlot.xlim(xmi, xma)
  PyPlot.xticks(xt, xl)
  return nothing
end
