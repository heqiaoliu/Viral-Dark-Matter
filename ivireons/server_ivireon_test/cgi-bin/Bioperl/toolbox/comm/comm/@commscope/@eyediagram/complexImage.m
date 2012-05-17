function complexImage(this, x)
%COMPLEXIMAGE   Plot real and imaginary parts separately using image

%   @commscope/@eyediagram
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/08/22 20:23:58 $

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

% If the PlotPDFRange is not set to full range, recalculate the color map
if ( any(this.PlotPDFRange ~= [0 1]) )
    this.PlotPDFRange = this.PlotPDFRange;
end

% Normalize the data to ColorMap size such that the minimum of the data
% corressponds to zero and maximum to color map size
cmapLen = size(get(this.PrivScopeHandle, 'ColorMap'), 1);
maxValRe = max(max(xRe));
maxValIm = max(max(xIm));
maxVal = max(maxValRe, maxValIm);
minValRe = min(min(xRe));
minValIm = min(min(xIm));
minVal = min(minValRe, minValIm);
if ( maxVal ~= minVal )
    xRe = cmapLen * (xRe-minVal) / (maxVal-minVal);
    xIm = cmapLen * (xIm-minVal) / (maxVal-minVal);
else
    if ( maxVal ~= 0 )
        xRe = cmapLen * xRe / maxVal;
        xIm = cmapLen * xIm / maxVal;
    elseif ( strcmp(this.ColorScale, 'log') )
        xRe = cmapLen + xRe;
        xIm = cmapLen + xIm;
    end
end

if ( all(strcmp(get(hPlotRe, 'Type'), 'image')) && ~this.PrivUpdateAxes )
    % if current figure is an image
    set(hPlotRe, 'CData', xRe);
    if this.PrivOperationMode
        set(hPlotIm, 'CData', xIm);
    end
else
    % This is a new image

    % Get time and amplitude vectors
    t = this.PrivHorBinCenters/this.SamplingFrequency;
    amp = this.PrivVerBinCenters;

    % Plot the data
    storeAxesInfo(this, hAxesRe, hAxesIm);
    image(t, amp, xRe, 'Parent', hAxesRe);
    set(hAxesRe, 'YDir', 'normal');
    if this.PrivOperationMode
        image(t, amp, xIm, 'Parent', hAxesIm);
        set(hAxesIm, 'YDir', 'normal');
    end
    updateAxesInfo(this, hAxesRe, hAxesIm);
end

%-------------------------------------------------------------------------------
% [EOF]
