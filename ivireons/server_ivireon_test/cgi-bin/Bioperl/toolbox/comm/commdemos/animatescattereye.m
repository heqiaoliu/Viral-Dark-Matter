function varargout = animatescattereye(x, nSamps, pausetime, ...
    offsetValues, hEyeScope)
% ANIMATESCATTEREYE - Does animation of moving offsets for
%                     scattereyedemo
%
%   ANIMATESCATTEREYE(X, NSAMPS, PAUSETIME, OFFSETVALUES, HEYESCOPE)
%   synchronously animates eye diagram and scatter plots to support the
%   SCATTEREYEDEMO demonstration in comm/commdemos.  This file uses an existing
%   eye scope and creates a scatter plot in the lower left corner of the screen.
%   Then, it plots the data in X into the scatter plot.  The required arguments
%   are as follows:
%
%   X is a matched filtered received signal.
%
%   NSAMPS is the number of samples used to represent a symbol.
%
%   PAUSETIME is the time to pause between animation steps.
%
%   OFFSETVALUES is the sampling offset values in seconds that will be animated.
%
%   HEYESCOPE is the handle to the existing eye diagram scope.
%
%   See also SCATTERPLOT, EYEDIAGRAM, SCATTEREYEDEMO.

%   Copyright 1996-2007 The MathWorks, Inc.
%   $Revision: 1.4.4.3 $ $Date: 2007/06/08 15:53:31 $

error(nargchk(5,5,nargin));
error(nargoutchk(0,1,nargout));

h = [];
for offset = offsetValues*hEyeScope.SamplingFrequency

    % Plot the symbol trace
    h = scatterplot(x, ...
        1, ...
        0, ...
        'c-', ...
        h);
    sp = get(h,'position');
    ep = get(hEyeScope.PrivScopeHandle, 'Position');
    set(h,'position',[15+ep(3) ep(2)+ep(4)-sp(4) sp(3) sp(4)]);
    hold on;

    % Plot the sampling points
    h = scatterplot(x, ...
        nSamps, ...
        round(mod(offset, nSamps)), ...
        'b*', ...
        h);

    % Plot the perfect sampling points
    h = scatterplot(x, ...
        nSamps, ...
        0, ...
        'r.', ...
        h);
    hold off;

    % Update the eye diagram
    hEyeScope.PlotTimeOffset = offset/hEyeScope.SamplingFrequency;
    addBestSamplingLine(hEyeScope);

    pause(pausetime)
end
if(nargout == 1)
    varargout(1) = {h};
end

%------------------------------------------------------------------------
function addBestSamplingLine(h)

hAxis = get(h.PrivScopeHandle, 'Children');
hRe = hAxis(end);
hIm = hAxis(end-1);

hold(hRe, 'on');
hold(hIm, 'on');
hl = plot(hRe, [1 1]/h.SymbolRate, ...
    [h.MinimumAmplitude h.MaximumAmplitude]);
set(hl, 'LineWidth', 2, 'LineStyle', '-', 'Color', 'b');
hl = plot(hIm, [1 1]/h.SymbolRate, ...
    [h.MinimumAmplitude h.MaximumAmplitude]);
set(hl, 'LineWidth', 2, 'LineStyle', '-', 'Color', 'b');

hold(hRe, 'off');
hold(hIm, 'off');

%------------------------------------------------------------------------
% [EOF]     