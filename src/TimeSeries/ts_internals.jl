# Formatted X labels
function xfmt(xmi::Int64, xma::Int64, yflag::Bool; fmt="auto"::String, auto_x=true::Bool, N=4::Int)
  dt = (xma-xmi)
  if fmt == "auto"
    if dt*μs < 3600
      fmt ="%M:%S"
      xstr = @sprintf("Time [%s] from %s:00:00 (UTC)",fmt,Libc.strftime("%Y-%m-%d %H",tzcorr()+xmi*μs))
    elseif dt*μs < 86400
      fmt ="%T"
      xstr = @sprintf("Time [%s], %s (UTC)",fmt,Libc.strftime("%Y-%m-%d",tzcorr()+xmi*μs))
    elseif yflag
      fmt ="%Y-%m-%d %H:%M:%S"
      xstr = @sprintf("Time [%s] (UTC)",fmt)
    else
      fmt ="%d %b %T"
      xstr = @sprintf("Time [%s] (UTC), %s",fmt,Libc.strftime("%Y",tzcorr()+xmi*μs))
    end
    xlabel(xstr)
  else
    xlabel(@sprintf("Time [%s]",replace(fmt, "%", "")))
  end
  dt /= 3

  if auto_x
    xt = Array{Float64,1}[]
    xl = Array{String,1}[]
    for i = 1:N
      xt = cat(1, xt, xmi+(i-1)*dt)
      xl = cat(1, xl, Libc.strftime(fmt,xt[i]*μs))
    end
    xlim(xmi, xma)
    xticks(xt, xl)
  end
  return nothing
end
