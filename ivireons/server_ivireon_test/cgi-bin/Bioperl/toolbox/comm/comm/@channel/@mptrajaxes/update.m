function update(h, snapshotIdx);
%UPDATE  Plot channel snapshot for multipath trajectory axes object.

%   Copyright 1996-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/12/27 20:28:05 $

hAxes = h.AxesHandle;

vec = h.OldChannelData;
v = h.NewChannelData;

n = h.SampleIdxVector(snapshotIdx);
vv = [vec(n+1:end) v(end, h.SampleIdxEndOld+(1:n))];
v1 = v(:, h.SampleIdxEndOld+n);

v11 = v1(:, 1).';
N = length(v11);
vr = real(v11);
vi = imag(v11);
nv = 1:N-1;
vr2 = [0 vr(nv); vr];
vi2 = [0 vi(nv); vi];

if (h.FirstPlot)
    
   % Clear, select, and hold axes.
    cla(hAxes);
    axes(hAxes);
    hold(hAxes, 'on');
    
    axis(hAxes, [-3 3 -3 3]);
    axis(hAxes, 'square');
    
    h.PlotHandles.v1 = plot(hAxes, vr2, vi2, '-', 'linewidth', 2);    
    %h.PlotHandles.vec = plot(vec, '.', 'markersize', 5, 'color', [0 0.5 0]);
    h.PlotHandles.vec = plot(hAxes, vv, '.', 'markersize', 5, 'color', [0 0.5 0]);
    
    hold(hAxes, 'off');

    grid(hAxes, 'on');
    
    hp = h.PlotHandles;
    setplotcolors(h, hp.v1);
    
    h.FirstPlot = false;
    
else

    hp = h.PlotHandles;
    
    for n = 1:N
        set(hp.v1(n), 'xdata', vr2(:, n), 'ydata', vi2(:, n));
    end

    set(hp.vec, 'xdata', real(vv), 'ydata', imag(vv));  
    
end
