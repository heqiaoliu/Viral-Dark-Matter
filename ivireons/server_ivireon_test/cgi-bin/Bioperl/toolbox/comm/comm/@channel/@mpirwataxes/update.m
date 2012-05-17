function update(h, snapshotIdx)
%UPDATE  Plot channel snapshot for multipath impulse response axes object.

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2010/05/20 01:58:11 $

hAxes = h.AxesHandle;

zOld = h.OldChannelData;
zNew = h.NewChannelData;

P = 10;

n = h.SampleIdxVector(snapshotIdx);
z = fliplr([zOld(:, n+1:end) zNew(:, h.SampleIdxEndOld+(1:n))]);
ii = round(linspace(1, size(z,2), P));
z = z(:, ii);

if (h.FirstPlot)

   % Clear, select, and hold axes.
    cla(hAxes);
    axes(hAxes); %#ok<MAXES>
    hold(hAxes, 'on');
    
    tgS = h.ChannelSmoothIRTimeDomain;
    t = -h.TimeDomain(ii);
    x = [tgS(1) tgS tgS(end)];
    u = ones(size(x));
    h.PlotHandles = zeros(1, 10);
    c = zeros(1, 10, 3);
    c(:, :, 1) = linspace(0.5, 0.89, 10);
    c(:, :, 2) = linspace(0.7, 0.99, 10);
    c(:, :, 3) = linspace(0.5, 0.89, 10);
    for n = 1:P
        tn = t(n);
        y = tn(u);
        h.PlotHandles(n) = patch(x, y, [0; z(:, n); 0]', c(:, n, :), 'Parent', hAxes);
        hh = h.PlotHandles(n);
        set(hh, 'FaceAlpha', 0.75);  %0.9
        set(hh, 'EdgeAlpha', 1);
        set(hh, 'EdgeColor', 0.6*n/P*ones(1,3));
    end
    set(hAxes, 'ydir', 'reverse');
    axis(hAxes, [tgS(1) tgS(end) t(end) t(1) 0 4]);
    view(hAxes, [-10, 60]);
    grid(hAxes, 'on');
    zlabel(hAxes, 'Magnitude');
    
    hold(hAxes, 'off');
    
    h.FirstPlot = false;
    
else
    for n = P:-1:1
        set(h.PlotHandles(n), 'zdata', [0; z(:, n); 0]);
    end
end







