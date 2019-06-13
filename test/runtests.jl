ENV["MPLBACKEND"]="agg" # no GUI
using SeisIO, SeisIO.RandSeis, PlotSeis
using Random: randn
using Dates: now
using Printf: @sprintf
path = Base.source_dir()
cd(dirname(pathof(PlotSeis))*"/../test")
test_start = now()
printstyled(stdout, string(test_start, ": tests begin, source_dir = ", path, "/\n"), color=:light_green, bold=true)

printstyled("Generating data\n", color=:light_green, bold=true)
n = (1,3,5,10,15,20,23,25)
A = Array{SeisData,1}(undef, 8)
A[1] = SeisData(randSeisChannel(s=true))
A[1].x[1] = randn(100000)
A[1].t[1] = [1 0; 100000 0]
for i = 2:8
  A[i] = randSeisData(n[i])
end

printstyled("Testing plots\n", color=:light_green, bold=true)
for S in A
  plotseis(S)
  uptimes(S)
  uptimes(S, summed=true)
  for i=1:3
    close()
  end
  if length(S.x[1]) ≥ 10000 && S.fs[1] > 0.0
    logspec(S, 1, fmin=0.01)
    close()
  end
end

test_end = now()
δt = 0.001*(test_end-test_start).value
mm = round(Int, div(δt, 60))
ss = rem(δt, 60)
printstyled(string(test_end, ": tests end, elapsed time (mm:ss.μμμ) = ",
                          @sprintf("%02i", mm), ":",
                          @sprintf("%06.3f", ss), "\n"), color=:light_green, bold=true)
