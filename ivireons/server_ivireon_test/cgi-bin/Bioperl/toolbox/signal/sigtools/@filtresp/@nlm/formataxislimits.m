function formataxislimits(this)
%FORMATAXISLIMITS

%   Author(s): J. Schickler
%   Copyright 2005-2006 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2006/06/27 23:37:59 $

h = get(this, 'Handles');

ydata = get(h.line, 'YData');
xdata = get(h.line, 'XData');

if isempty(ydata)
    return;
end

% Compute global Y-axis limits over potentially
% multiple filter magnitude responses
%
yMin =  Inf;  % min global y-limit
yMax = -Inf;  % max global y-limit
xMin =  Inf;
xMax = -Inf;
if ~iscell(ydata)
    ydata = {ydata};
    xdata = {xdata};
end
for indx = 1:length(ydata) % Loop over the filter responses.
    thisMag = ydata{indx};

    % Estimate y-limits for dB plots
    thisYlim = freqzlim_dB(thisMag);
    
    yMin = min(yMin, thisYlim(1));
    yMax = max(yMax, thisYlim(2));
    xMin = min(xMin, min(xdata{indx}));
    xMax = max(xMax, max(xdata{indx}));
end

% Make sure that the yMin and yMax aren't exactly equal.  This can happen
% in the GRPDELAY case for linear phase filters or in magnitude for all
% pass filters.
if yMin == yMax
    yMin = yMin-.5;
    yMax = yMax+.5;
end

set(h.axes, 'YLim',[yMin yMax], 'XLim', [xMin xMax]);

% --------------------------------------------------------------------
function ylim = freqzlim_dB(mag)
% Estimate Y-axis limits to view magnitude dB response
% Algorithm:
%  - Estimate smoothed envelope of dB response curve,
%    to avoid "falling into nulls" in ripple regions
%  - Add a little "extra space" (margin) at top and bottom
%
% Note: we do NOT use the max and min of the response itself
%     - min is an overestimate often going to -300 dB or worse
%     - max is an underestimate causing the response to hit axis
%
% Returns:
%   ylim: vector of y-axis display limits, [ymin ymax]

MarginTop = 0.03;  % 3% margin of dyn range at top
MarginBot = 0.10;  % 10% margin at bottom

% Determine default margins
%
% Remove non-finite values for dynamic range computation
magf = mag;
magf(find(~isfinite(magf)))=[];
dr = max(magf)-min(magf);  % "modified" dynamic range

% Handle the null case.
if isempty(dr)
    ylim = [0 1];
    return;
end

% Length of sliding window to compute "localized maxima" values
% We're looking for the MINIMUM of the ENVELOPE of the input curve (mag).
% The true envelope is difficult to compute due as it is positive-only
% The length of the sliding window is important:
%  - too long: envelope estimate is biased toward "global max"
%              and we lose accuracy of envelope minimum
%  - too short: we fall into "nulls" and we're no longer tracking envelope
%
% Set window to 5% of input length, minimum of 3 samples
Nspan = max(3, ceil(0.1*numel(mag)));

% Compute mag envelope, derive y-limit estimates
env  = MiniMax(mag, Nspan);
ymin = min(env) - dr*MarginBot;  % Lower by fraction of dynamic range
ymax = max(mag) + dr*MarginTop;  % Raise by fraction of dynamic range
ylim = [ymin ymax];

% --------------------------------------------------------------------
function spanMin = MiniMax(mag,Nspan)
%MiniMax Find the minimum of all local maxima, with each
%  maxima computed over NSPAN-length segments of input.

Nele=numel(mag);
if Nele<Nspan
    spanMin = min(mag);
else

    
    % This is the original code in its more MATLABish form.  This is not
    % "JIT friendly" so was very slow.  The longer code below is actually
    % must faster with the same exact functionality.
%     spanMin=inf;
%     Ns1=Nspan-1;
%     for i=1:Nele-Ns1
%         spanMin = min(spanMin,max(mag(i:i+Ns1)));
%     end
    
    % General case
    spanMin = max(mag(1:Nspan)); % max computed over first span
    intMax = spanMin;            % interval max computed over all spans
    for i = 1:Nele-Nspan         % already did first span (above!)
        % Overall equivalent code for this section:
        %   spanMin = min(spanMin,max(mag(i:i+Ns1)));
        %
        % Update intMax, the maximum found over the current interval
        % The "update" is to consider just (a) the next point to bring
        % into the interval, and (b) the last point dropped out of the
        % interval.  This produces an efficient "slide by 1" max result.
        %
        % Equivalent code:
        %   intMax = max(mag(i:i+Ns1));
        pAdd = mag(i+Nspan);  % add point
        if pAdd > intMax
            % just take pAdd as new max
            intMax = pAdd;
        elseif mag(i) < intMax  % Note: pDrop = mag(i-1)
            % just add in effect of next point
            intMax = max(intMax, pAdd);
        else
            % pDrop == last_intMax: recompute max
            intMax = max(mag(i+1 : i+Nspan));
        end
        % Equivalent code:
        %   spanMin = min(spanMin,intMax);
        if spanMin > intMax
            spanMin = intMax;
        end
    end
end

% [EOF]
