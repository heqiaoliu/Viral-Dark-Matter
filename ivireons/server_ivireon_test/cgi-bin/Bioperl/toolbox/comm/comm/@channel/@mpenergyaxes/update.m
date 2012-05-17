function update(h, snapshotIdx)
%UPDATE  Plot channel snapshot for multipath components axes object.

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2010/05/20 01:58:10 $

hAxes = h.AxesHandle;

EOld = h.OldChannelData;
ENew = h.NewChannelData;

n = h.SampleIdxVector(snapshotIdx);
E = [EOld(n+1:end, :); ENew(h.SampleIdxEndOld+(1:n), :)].';

if (h.FirstPlot)

    % Clear, select, and hold axes.
    cla(hAxes);
    axes(hAxes); %#ok<MAXES>
    hold(hAxes, 'on');
    
    t = h.TimeDomain - h.TimeDomain(end);
    h.PlotHandles = ...
        plot(hAxes, t, E(1,:), 'r-', t, E(2,:), 'b--', t, E(3,:), 'm.');
    h.AuxObjHandles = ...
        legend(hAxes, '\infty BW', 'Signal BW', 'Narrowband', 'Location', 'southwest');
    
    hold(hAxes, 'off');

    h.FirstPlot = false;
else
    hg = h.PlotHandles;
    for p = 1:3
        set(hg(p), 'ydata', E(p, :));
    end
end
