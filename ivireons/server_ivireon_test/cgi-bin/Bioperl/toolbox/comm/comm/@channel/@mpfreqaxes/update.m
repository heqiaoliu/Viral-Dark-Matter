function update(h, snapshotIdx);
%UPDATE  Plot channel snapshot for multipath impulse response axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 20:28:00 $

hAxes = h.AxesHandle;

newData = h.NewChannelData;

idx = h.SampleIdxEndOld + h.SampleIdxVector(snapshotIdx);
MagHdB = newData.MagHdB(idx, :);

if (h.FirstPlot)

   % Clear, select, and hold axes.
    cla(hAxes);
    axes(hAxes);
    hold(hAxes, 'on');
    
    fmax = newData.fmax;
    f = newData.f;

    h.PlotHandles.MagHdB = plot(hAxes, f, MagHdB, '-', 'color', [0 0.5 0]);
    axis(hAxes, [-fmax fmax -40 10]);
    
    hold(hAxes, 'off');

    h.FirstPlot = false;

else

    set(h.PlotHandles.MagHdB, 'ydata', MagHdB);

end
