function [m, xunits] = objspecificdraw(this)
%OBJSPECIFICDRAW Draw the groupdelay
%   Passes back the frequency vector multiplier and the xunits

%   Author(s): J. Schickler
%   Copyright 1988-2006 The MathWorks, Inc.
%   $Revision: 1.3.6.12 $  $Date: 2006/06/27 23:37:55 $

Hd   = get(this, 'Filters');

h      = get(this, 'Handles');
h.axes = h.axes(end);

if isempty(Hd),
    m = 1;
    xunits = '';
    ylbl = 'Group delay (in samples)';
    h.line = [];
else
    opts = getoptions(this);

    optsstruct.showref  = showref(this.FilterUtils);
    optsstruct.showpoly = showpoly(this.FilterUtils);
    optsstruct.sosview  = get(this, 'SOSViewOpts');

    [Gall, W] = grpdelay(Hd, opts{:}, optsstruct);

    % Apply the samples/time parameter
    if strcmpi(get(this, 'GroupDelay'), 'time') && ~isempty(getmaxfs(Hd)),
        for indx = 1:length(Hd),

            fs = get(Hd(indx), 'Fs');
            if isempty(fs), fs = getmaxfs(Hd); end

            Gall{indx} = Gall{indx}/fs;
        end
        [Gall, m, units] = cellengunits(Gall);
        ylbl = sprintf('Group delay in time (%ss)', units);
    else
        ylbl = 'Group delay (in samples)';
    end

    [W, m, xunits] = normalize_w(this, W);

    if ishandlefield(this,'line') && length(h.line) == size(Gall{1}, 2)
        for indx = 1:size(Gall{1}, 2)
            set(h.line(indx), 'xdata',W{1}, 'ydata',Gall{1}(:,indx));
        end
    else
        h.line = freqplotter(h.axes, W, Gall);
    end
end

hylbl = ylabel(h.axes, xlate(ylbl));

if ~ishandlefield(this, 'grpdelaycsmenu')
    if ~isempty(Hd)
        if ~isempty(getmaxfs(Hd))
            h.grpdelaycsmenu = contextmenu(getparameter(this, 'grpdelay'), hylbl);
        end
    end
elseif isempty(getmaxfs(this.Filters))
    delete(h.grpdelaycsmenu);
    h = rmfield(h, 'grpdelaycsmenu');
end

set(this, 'Handles', h);

% [EOF]
