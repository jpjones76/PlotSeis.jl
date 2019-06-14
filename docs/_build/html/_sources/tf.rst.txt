Time-Frequency Plots
====================

.. function:: logspec(S::SeisData, k::Union{Int64,String}[, nx=1024, ov=0.5, fmin=0.5*fs/nx, fmax=0.5*fs, fmt="auto"])

Spectrogram of trace number or channel ID ``k`` with logarithmic scaling of the
y-axis (frequency). 

Keywords
********
* **nx** window length
* **ov** overlap fraction between adjacent windows
* **fmin** lowest frequency to plot
* **fmax** highest frequency to plot
