function update(h, snapshotIdx)
%UPDATE  Plot channel snapshot for multipath components axes object.

%   Copyright 1996-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/20 15:29:05 $

% Get axes and figure handles.
hAxes = h.AxesHandle;
fig = h.MultipathFigParent;

% Determine plot trace.
yOld = h.OldChannelData;
yNew = h.NewChannelData;
n = h.SampleIdxVector(snapshotIdx);
y = [yOld(:, n+1:end) yNew(:, h.SampleIdxEndOld+(1:n))];
N = size(y,1);

% Time-related parameters; time-axis markers and labels.
Ts = fig.CurrentChannel.InputSamplePeriod;
framePeriod = fig.FramePeriod;
frameTime = fig.FrameStartTime;
snapTime = fig.CurrentSnapshotTime;
tf1 = frameTime - snapTime + Ts + eps;
tf = tf1([1 1]);
tfstr = timestr(frameTime);
tStartStr = timestr(snapTime - framePeriod);
tEndStr = timestr(snapTime);

if (h.FirstPlot)
    
   % Clear, select, and hold axes.
    cla(hAxes);
    axes(hAxes);
    hold(hAxes, 'on');
    
    % Time domain
    t = h.TimeDomain;
    
    % Plot path traces and hold.
    hg.paths = plot(hAxes, t-t(end), y, '.', 'markersize', 5);
    
    % Plot frame start line.
    hg.t1 = plot(hAxes, tf, [-40 10], '--', ...
        'linewidth', 2, 'color', [0.7 0.7 0.7]);
            
    % Set time-axis limits and tick intervals.
    xMin = -(2*t(end)-t(end-1));
    xMax = 0;
    set(hAxes, 'xlim', [xMin xMax], 'ylim', [-40 10]);
    set(hAxes, 'xtick', linspace(xMin, xMax, 10));
    
    plottimelabels(hAxes, tStartStr, tEndStr);

    % Plot frame start marker.
    hg.markFrame = plot(hAxes, tf(1), -40, '^', ...
         'markersize', 10, 'markerface', [0.7 0.7 0.7], 'color', 'k');
   
    hold(hAxes, 'off');
    grid(hAxes, 'on');
    
    setplotcolors(h, hg.paths);
   
    h.PlotHandles = hg;
    
    h.FirstPlot = false;
    
else
    
    hg = h.PlotHandles;
    
    hp = hg.paths;
    for p = 1:N
        set(hp(p), 'ydata', y(p, :));
    end
    
    set(hg.t1, 'xdata', tf);
    set(hg.markFrame, 'xdata', tf1);
    
    plottimelabels(hAxes, tStartStr, tEndStr);

end

%--------------------------------------------------------------------------
function plottimelabels(hAxes, tStartStr, tEndStr)
% Time-axis labels.
xTicks = get(hAxes, 'xtick');
nTicks = length(xTicks);
%strvcat is used since it converts number 32 to blank spaces
ht = strvcat(tStartStr, 32*ones(nTicks-2,1), tEndStr); %#ok<VCAT>
set(hAxes, 'xticklabel', ht);

%--------------------------------------------------------------------------
function str = timestr(t)
if t<1e-15
    str = '0 s';
else
    [num,dummy,units] = engunits(t);
    str = sprintf('%s',num2str(num),' ', units, 's');   
end

