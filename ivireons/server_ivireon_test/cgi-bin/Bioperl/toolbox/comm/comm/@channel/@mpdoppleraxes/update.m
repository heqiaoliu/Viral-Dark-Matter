function update(h, snapshotIdx) %#ok
%UPDATE  Plot channel data for multipath doppler spectrum axes object.

%   Copyright 1996-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2010/05/20 01:58:09 $

hAxes = h.AxesHandle;

newData = h.NewChannelData;

f = newData.Frequencies;
S = newData.SpectrumValues;

% Number of Doppler spectra (including theoretical curve).
N = size(S, 1);

nPlotted = h.PathNumberPlotted;

if h.FirstPlot

   % Clear, select, and hold axes.
    cla(hAxes);
    hold(hAxes, 'on');
    
    lt = {{'r--'}, {'b.', 'markersize', 5}};

    % Plot Doppler spectra.
    
    lt1 = lt{1};
    hp(1) = plot(hAxes, f(nPlotted, :), S(nPlotted, :), lt1{:});
    
    lt2 = lt{2};
    hp(2) = plot(hAxes, f(nPlotted+N/2, :), S(nPlotted+N/2, :), lt2{:});
    
    h.AuxObjHandles = ...
        legend(hAxes, 'Theoretical', 'Measurement', 'Location', 'northeast');

    % Forces the 'Position' property of h.AxesHandle to stay the same as
    % the 'Position' property of h, because the legend command above
    % changes the width/height of the axes plot.
    % Bug in HG.
    set(hAxes,'Position', h.Position);
    
    % Set axes limits.
    fc = max(newData.CutoffFrequency);
    xmax = 1.5*fc;
    ymax = 1.5 * max(S(nPlotted, :));
    set(hAxes, 'xlim', [-xmax xmax], 'ylim', [0 ymax]);
    % Manually set YTickLabels because when in auto mode, 10^-x overlaps with
    % the title. When figure is resized, YTickLabels must be manually set again.
    zsc = cellstr(num2str(get(hAxes,'YTick')'));
    set(hAxes,'YTickLabel',zsc);

    hold(hAxes, 'off');

    h.PlotHandles = hp;
    h.FirstPlot = false;
    
else

    if newData.MeasurementsToBePlotted
        hp = h.PlotHandles;
        % Skip theoretical curve.
        set(hp(2), 'ydata', S(nPlotted+N/2, :));
    end
    
end

if newData.MeasurementsToBePlotted
    if length(h.PathDelays) == 1
        titleStr = 'Doppler Spectrum (Measured data updated)';
    else
        titleStr = ['Doppler Spectrum for path ' num2str(nPlotted) ...
           ' (Measured data updated)'];
    end
else
    chan = h.MultipathFigParent.CurrentChannel;
    r = chan.RayleighFading;
    intf = r.InterpFilter;
    fgStats = r.FiltGaussian.Statistics(1);
    numSampNeeded = ((fgStats.BufferSize - fgStats.IdxNext) + 1) ...
        * (intf.PolyphaseInterpFactor * intf.LinearInterpFactor);
    if (numSampNeeded>1)
        sStr = ' samples';
    else
        sStr = ' sample';
    end
    if length(h.PathDelays) == 1
        titleStr = ['Doppler Spectrum (Need ' num2str(numSampNeeded) ...
            sStr ' for new measurement)'];
    else
        titleStr = ['Doppler Spectrum for path ' num2str(nPlotted) ...
                ' (Need ' num2str(numSampNeeded) sStr ' for new measurement)'];
    end
end
hTitle = get(hAxes, 'title');
set(hTitle, 'string', titleStr);
    
% Always clear this flag.
h.NewChannelData.MeasurementsToBePlotted = false;

