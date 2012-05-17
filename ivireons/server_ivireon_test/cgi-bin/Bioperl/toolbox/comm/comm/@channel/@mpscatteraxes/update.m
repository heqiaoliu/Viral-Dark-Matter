function update(h, ~)
%UPDATE  Plot channel data for multipath scattering function axes object.

%   Copyright 2007-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/05/20 01:58:12 $

hAxes = h.AxesHandle;

newData = h.NewChannelData;

f = newData.Frequencies;
S = newData.SpectrumValues;

delays = h.PathDelays;
gains = h.AvgPathGainVector;

% Number of Doppler spectra (including theoretical curves).
N = size(S, 1);

if h.FirstPlot

   % Clear and hold axes.
    cla(hAxes);
    hold(hAxes, 'on');

    % Set axes limits.
    fc = max(newData.CutoffFrequency);
    xmax = 1.5*fc;
    % Only one path: center it.
    if length(delays) == 1
        if delays == 0
            ymin = -0.5;
            ymax = 0.5;
        else
            ymin = delays - abs(delays)/2;
            ymax = delays + abs(delays)/2;
        end   
    % Multiple paths.    
    else  
        ymin = min(delays);
        ymax = max(delays)*1.1;
    end
    zmax = 1.0 * max( max( S(1:N/2,:).*repmat((gains(:)).^2,1,size(S,2)) ) );
    set(hAxes, 'xlim', [-xmax xmax], 'ylim', [ymin ymax], 'zlim', [0 zmax]);
    
    axis(hAxes,'ij');       % y-axis origin in upper left corner
    view(hAxes, [-10, 60]); % Gives 3-D view
    % Manually set ZTickLabels because when in auto mode, 10^-x overlaps with
    % the title. When figure is resized, ZTickLabels must be manually set again.
    zsc = cellstr(num2str(get(hAxes,'ZTick')'));
    set(hAxes,'ZTickLabel',zsc);
    
    hp = zeros(1,N);
    % Plot Doppler spectra.
    for n = 1:N/2        
        dd = repmat(delays(n),1,size(f,2));
        % Data is truncated to fit within axis limits.
        hp(n) = plot3(f(n, abs(f(n,:))<xmax), dd(abs(f(n,:))<xmax), S(n, abs(f(n,:))<xmax)*(gains(n))^2, 'r--', 'Parent', hAxes);
    end
    for n = N/2+1:N
        dd = repmat(delays(n-N/2),1,size(f,2));
        % Data is truncated to fit within axis limits.
        hp(n) = plot3(f(n, abs(f(n,:))<xmax), dd(abs(f(n,:))<xmax), S(n, abs(f(n,:))<xmax)*(gains(n-N/2))^2, 'b.', 'markersize', 5, 'Parent', hAxes);
    end
    setplotcolors(h,hp(N/2+1:N));

    h.AuxObjHandles = ...
        legend(hAxes, [hp(1) hp(N/2+1)], 'Theoretical', 'Measurement', 'Location', 'NorthEast');
    hold(hAxes, 'off');

    h.PlotHandles = hp;
    h.FirstPlot = false;
    
else

    if newData.MeasurementsToBePlotted
        hp = h.PlotHandles;
        fc = max(newData.CutoffFrequency);
        xmax = 1.5*fc;
        for n = N/2+1:N  % Skip theoretical curves.
            set(hp(n), 'zdata', S(n, abs(f(n,:))<xmax)*(gains(n-N/2))^2);
        end
    end
    
end

if newData.MeasurementsToBePlotted
    titleStr = 'Scattering Function (Measured data updated)';
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
    titleStr = ['Scattering Function (Need '  num2str(numSampNeeded) ...
        sStr ' for new measurement)'];
end
hTitle = get(hAxes, 'title');
set(hTitle, 'string', titleStr);
    
% Always clear this flag.
h.NewChannelData.MeasurementsToBePlotted = false;
