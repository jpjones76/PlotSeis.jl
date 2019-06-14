Time-Series Plots
=================

.. function:: plotseis(S::SeisData[, fmt="auto", use_name=false, nxt=5)])

Normalized trace plot of data in ``S``. Time-series data use lines; irregularly-
sampled data are plotted with circles.

.. function:: uptimes(S::SeisData[, summed=false, fmt="auto", use_name=false])

Plot uptimes of each channel in ``S`` using filled, colored bars.

If ``summed==true``, plot uptimes for all channels in S that record timeseries data,
scaled so that y=1 corresponds to 100% of channels active. Non-timeseries
channels in S are not counted toward the cumulative total in a summed uptime plot.

Keywords
********

* ``fmt=FMT`` formats x-axis labels using C-language ``strftime`` format string ``FMT``. If unspecified, the format is determined by when data in ``S`` start and end.
* ``use_name=true`` uses ``S.name``, rather than ``S.id``, for trace labels.
* ``n=N`` sets the number of X-axis ticks to N.
