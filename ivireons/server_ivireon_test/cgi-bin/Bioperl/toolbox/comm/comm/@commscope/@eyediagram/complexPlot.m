function complexPlot(this, x, varargin)
%COMPLEXPLOT   Plot real and imaginary parts separately using plot

%   @commscope/@eyediagram
%
%   Copyright 2007-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2008/08/22 20:24:00 $

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

if ( ~isempty(hPlotRe) && all(strcmp(get(hPlotRe, 'Type'), 'line')) ...
        && (nargin == 2) && (length(hPlotRe) == size(x,2)) ...
        && (size(get(hPlotRe(1), 'YData'), 2) == size(x,1)) ...
        && ~this.PrivUpdateAxes)
    % if current figure is a line plot
    for p=1:length(hPlotRe)
        set(hPlotRe(p), 'YData', real(x(:,p)));
        if this.PrivOperationMode
            set(hPlotIm(p), 'YData', imag(x(:,p)));
        end
    end
else
    % This is a new line plot

    % If no line spec is specified, use 'b' as default
    if ( isempty(varargin) )
        varargin = {'b'};
    end

    % Replicate the data points at t=0 at t(end+1) to obtain a symmetric eye
    x = [x; [x(1,2:end) NaN]];

    % Get time and amplitude vectors
    t = (0:size(x,1)-1)/this.SamplingFrequency;

    % Plot the in-phase data
    storeAxesInfo(this, hAxesRe, hAxesIm);
    plot(t, real(x), varargin{:}, 'Parent', hAxesRe);
    % Tighten the x-axis
    set(hAxesRe, 'XLim', [t(1) t(end)]);
    if this.PrivOperationMode
        % Plot the qudrature data
        plot(t, imag(x), varargin{:}, 'Parent', hAxesIm);
        % Tighten the x-axis
        set(hAxesIm, 'XLim', [t(1) t(end)]);
    end
    updateAxesInfo(this, hAxesRe, hAxesIm);
end

%-------------------------------------------------------------------------------
% [EOF]
