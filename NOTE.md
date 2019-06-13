## About the choice of PyPlot

`PyPlot` was not intended to be the permanent graphics back-end for PlotSeis. However, we encountered breaking issues as recently as June 2019 with every other popular Julia graphics package:
* `GR` is unstable, poorly documented, and lacks customization.
  + In my tests, calling `uptimes` after `plotseis` was >50% likely to cause a segmentation fault and core dump Julia; the reverse was also true.
  + GR depends on QT as an external back-end; while QT is more standardized than `matplotlib`, many external Linux packages are needed for it to work.
* `InspectDR` and `PGFPlots` can't create spectrograms or similar "heat map" figures.
* `plotlyjs` is profoundly slow and memory-intensive.
  + On an Intel(R) Core(TM) i7-7500U CPU @ 2.70GHz with nVidia GeForce 940MX and 12 GB RAM, line plots stall after 8-10 traces and require >30 seconds to reach the "stall" point.
  + Increasing line width to 2.0 when plotting lines with ~10^5 points consumes so much memory that Ubuntu 18.04 hangs, forcing a hard reset.
* `plotly` uses browser windows, lacks Julia documentation, and lacks customization.
* `Makie` was not tested because `test Makie` failed repeatedly with all dependencies satisfied:
```
(v1.1) pkg> test Makie
   Testing Makie
 ...
running tutorial_simple_scatter
ERROR: LoadError: MethodError: no method matching
backend_show(::Missing, ::IOContext{IOStream},
::MIME{Symbol("image/jpeg")}, ::Scene)
```

For the forseeable future, we will continue to develop PlotSeis based on PyPlot. We are amenable to an eventual switch to another engine (e.g., GR, Makie, or plotly) once their packages stabilize and more customization becomes available.
