function complexSurf(this, x)
%COMPLEXSURF    Plot real and imaginary parts separately using image

%   @commscope/@eyediagram
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.7 $  $Date: 2008/08/22 20:24:01 $

% If the PlotPDFRange is not set to full range, reset the color map
if ( any(this.PlotPDFRange ~= [0 1]) )
    set(this.PrivScopeHandle, 'ColorMap', this.PrivColorMap);
end

% Get current real plot
hAxesRe = findall(this.PrivScopeHandle, 'Tag', 'InPhaseAxes');
hPlotRe = get(hAxesRe, 'Children');
if this.PrivOperationMode
    % Get current imaginary plot
    hAxesIm = findall(this.PrivScopeHandle, 'Tag', 'QuadratureAxes');
    hPlotIm = get(hAxesIm, 'Children');
else
    hAxesIm = [];
    hPlotIm = [];
end

% Get the data
xRe = real(x);
xIm = imag(x);

% Check if log scale
if ( strcmp(this.ColorScale, 'log') )
    % Remove zeros
    xRe(xRe==0) = NaN;
    xIm(xIm==0) = NaN;

    xRe = log10(xRe);
    xIm = log10(xIm);
end

% Check if we need to redraw
if strncmp(get(hPlotRe, 'Type'), 'surface', 7)
    % Current figure is surface
    currentSize = size(get(hPlotRe, 'ZData'));
    newSize = size(xRe);
    if any(currentSize ~= newSize)
        % The data size has changed, redraw
        this.PrivUpdateAxes = 1;
    end
else
    % Current figure is not surface, redraw
    this.PrivUpdateAxes = 1;
end

if ~this.PrivUpdateAxes
    % if current figure is a surf
    set(hPlotRe, 'ZData', xRe);
    if this.PrivOperationMode
        set(hPlotIm, 'ZData', xIm);
    end
else
    % This is a new image

    % Get time and amplitude vectors
    t = this.PrivHorBinCenters/this.SamplingFrequency;
    amp = this.PrivVerBinCenters;

    % Plot the data
    storeAxesInfo(this, hAxesRe, hAxesIm);
    surf(t, amp, xRe, 'Parent', hAxesRe, 'EdgeAlpha', 0);
    set(hAxesRe, 'view', [-55 70]);
    if this.PrivOperationMode
        surf(t, amp, xIm, 'Parent', hAxesIm, 'EdgeAlpha', 0);
        set(hAxesIm, 'view', [-55 70]);
    end
    updateAxesInfo(this, hAxesRe, hAxesIm);
end

%-------------------------------------------------------------------------------
% [EOF]
