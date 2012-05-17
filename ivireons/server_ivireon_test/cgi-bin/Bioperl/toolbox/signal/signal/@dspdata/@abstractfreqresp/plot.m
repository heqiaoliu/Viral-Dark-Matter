function varargout = plot(this)
%PLOT   Plot the response.

%   Author(s): J. Schickler
%   Copyright 1988-2009 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2009/09/03 05:27:53 $

if length(this) > 1
    error(generatemsgid('InvalidInputs'), 'The PLOT method does not support vectors of objects.');
end

normfreq = get(this, 'NormalizedFrequency');

% Determine the frequency range to plot.
freqrange = 'whole';
if ishalfnyqinterval(this)
    freqrange = 'half';
end
centerdc = getcenterdc(this);

% Create a new plot or reuse an available one.
hax = newplot;
    
% Get the data from this object.
[H, W] = getdata(this,isdensity(this),plotindb(this),normfreq,freqrange,centerdc);

% Set up the xlabel.
if normfreq
    W    = W/pi;
    xlbl = getfreqlbl('rad/sample');
else
    [W, m, xunits] = engunits(W);
    xlbl = getfreqlbl([xunits 'Hz']);
end

% Plot the data.
h = line(W, H, 'Parent', hax);

if((strcmp(this.Name, 'Power Spectral Density') || strcmp(this.Name, 'Mean-Square Spectrum')) && ~isempty(this.ConfInterval))
    CI = this.ConfInterval;
    CL = this.ConfLevel;   
    Hc = db(CI,'power');
    % Plot the Confidence Intervals.
    h(2) = line(W, Hc(:,1),'color',[0.4 0.5 0.5],'LineStyle','-.','Parent', hax);
    h(3) = line(W, Hc(:,2),'color',[0.4 0.5 0.5],'LineStyle','-.','Parent', hax); 
    Estimate = this.Name;
    Interval = strcat(num2str(CL*100),'%' ,' Confidence Interval');
    legend(Estimate,Interval,'Location','best');    
end

xlabel(hax, xlate(xlbl));

% Set up the ylabel
ylabel(hax, xlate(getylabel(this)));

title(hax, xlate(gettitle(this)));

set(hax, 'Box', 'On', ...
    'XGrid', 'On', ...
    'YGrid', 'On', ...
    'XLim', [min(W) max(W)]);

% Ensure axes limits are properly cached for zoom/unzoom
resetplotview(hax,'SaveCurrentView'); 

if nargout
    varargout = {h};
end

% [EOF]
