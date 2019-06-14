## About the choice of PyPlot

PyPlot is not intended as a permanent graphics backend for SeisIO visualization. However, we encountered breaking issues as recently as June 2019 with every other Julia graphics package:
* `GR` is unstable, poorly documented, and lacks customization.
  + In my tests, calling `uptimes` after `plotseis` was >50% likely to cause a segmentation fault and core dump Julia; the reverse was also true.
  + GR depends on QT as an external back-end; while QT is more standardized than `matplotlib`, many external Linux packages are needed for it to work.
* `plotlyjs` is profoundly slow and memory-intensive.
  + On an Intel(R) Core(TM) i7-7500U CPU @ 2.70GHz with nVidia GeForce 940MX and 12 GB RAM, line plots stall after 8-10 traces per plot and require >30 seconds to reach that point.
  + Increasing line width to 2.0 when plotting lines with ~10^5 points consumes so much memory that Ubuntu 18.04 hangs, forcing a hard reset.
* `plotly` uses browser windows, lacks Julia documentation, and lacks axis customization.
 
