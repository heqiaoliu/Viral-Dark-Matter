function update(h, snapshotIdx);
%UPDATE  Plot channel snapshot for multipath impulse response axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 20:28:02 $

hAxes = h.AxesHandle;

newData = h.NewChannelData;

idx = h.SampleIdxEndOld + h.SampleIdxVector(snapshotIdx);
Magz = newData.Magz(idx, :);
Magg = newData.Magg(idx, :);
MaggS = newData.MaggS(idx, :);
MaggOut = newData.MaggOut(idx, :);

% Compute stem points for path gains.
uNaN = NaN;
mzmat = [zeros(size(Magz)); Magz;  uNaN(ones(size(Magz)))];
MagzStem = mzmat(:).';

N = length(Magz);

if (h.FirstPlot)
    
   % Clear, select, and hold axes.
    cla(hAxes);
    axes(hAxes);
    hold(hAxes, 'on');
    
    tau = h.PathDelays;
    tzp = newData.tzp;
    tg = h.ChannelIRTimeDomain;
    tgS = h.ChannelSmoothIRTimeDomain;
    tgOut = newData.tgOut;
    
    hp.Magz = plot(hAxes,tau([1 1], :), [uNaN(ones(1,N)); Magz], 'ro');
    hp.MagzStem = plot(hAxes, tau([1 1], :), ...
        [zeros(1,N); Magz], 'r-', 'linewidth', 2);
    hp.Magg = plot(hAxes, tg, Magg, '.', 'markersize', 15);
    hp.MaggOut = plot(hAxes, tgOut, MaggOut, 'o', 'markersize', 5);
    hp.MaggS = plot(hAxes, tgS, MaggS, '-', 'linewidth', 1);
    
    h.PlotHandles = hp;
    setplotcolors(h, hp.Magz);
    setplotcolors(h, hp.MagzStem);
    set([hp.Magg hp.MaggOut hp.MaggS], 'color', [0 0.5 0]);
    
    hold(hAxes, 'off');
    
    h.FirstPlot = false;
    
else
    
    hp = h.PlotHandles;
    for n = 1:N
        set(hp.Magz(n), 'ydata', [uNaN Magz(n)]);
        set(hp.MagzStem(n), 'ydata', [0 Magz(n)]);
    end
    set(hp.Magg, 'ydata', Magg);
    set(hp.MaggS, 'ydata', MaggS);
    set(hp.MaggOut, 'ydata', MaggOut);
    
end
