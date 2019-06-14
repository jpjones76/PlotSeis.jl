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
n = (4,5,10,15,20,23,25)
A = Array{SeisData,1}(undef, 10)
for i = 1:7
  A[i] = randSeisData(n[i])
end

S = SeisData(randSeisChannel(s=true))
S.x[1] = randn(200000)
S.fs[1] = 50.0
S.t[1] = [1 -100000; 200000 0]
A[8] = deepcopy(S)

S.t[1] = [1 1; 200000 0]
A[9] = deepcopy(S)

S.x[1] = randn(2000)
S.t[1] = [1 0; 2000 0]
S.fs[1] = 4000.0
A[10] = deepcopy(S)

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

plotseis(S, fmt = "%H:%M:%S")

test_end = now()
δt = 0.001*(test_end-test_start).value
mm = round(Int, div(δt, 60))
ss = rem(δt, 60)
printstyled(string(test_end, ": tests end, elapsed time (mm:ss.μμμ) = ",
                          @sprintf("%02i", mm), ":",
                          @sprintf("%06.3f", ss), "\n"), color=:light_green, bold=true)
