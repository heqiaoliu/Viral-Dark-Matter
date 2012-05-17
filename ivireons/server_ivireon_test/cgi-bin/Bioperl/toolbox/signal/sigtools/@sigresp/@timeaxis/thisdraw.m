function thisdraw(this)
%THISDRAW Draw the time response

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.12 $  $Date: 2006/12/27 21:30:28 $

deletelineswithtag(this);

set(getbottomaxes(this), 'YLimMode', 'Auto');

setupaxes(this);

units = updateplot(this);

setuplabels(this, units);

% -----------------------------------------------------------------
function units = updateplot(this)

[H, T] = getplotdata(this);

h = get(this, 'Handles');

if isempty(H),
    units = '';
    h.line = [];
else

    if strcmpi(get(this, 'NormalizedFrequency'), 'on')

        filtindx = 1;
        fs = getmaxfs(this);

        if ~isempty(fs)
            for indx = 1:length(T),
                T{indx} = T{indx}*fs;
            end
        end
        units = [];
    else
        [T, e, units] = cellengunits(T);
    end

    hPlot = getparameter(this, 'plottype');
    ax    = h.axes;
    ptype = get(hPlot, 'Value');
    h.line = [];
    type  = find(strcmpi(hPlot.Value, hPlot.ValidValues));
    nresps = 0;
    np    = get(ax, 'NextPlot'); set(ax, 'nextplot','add');
    npfig = get(this.FigureHandle, 'NextPlot');
    for indx = 1:length(H),

        for jndx = 1:size(H{indx},2)
        
            nresps = nresps+1;
            
            color = getlinecolor(this, length(h.line)+1);
            
            if type == 2  % Stem
                ht = stem(ax, T{indx}, real(H{indx}(:, jndx)), 'filled');
            else          % Line and Line with Marker
                ht = line(T{indx},real(H{indx}(:,jndx)),'parent',ax);
            end
            
            if ~isreal(H{indx})
                if type == 2  % Stem
                    ht(2) = stem(ax, T{indx}, imag(H{indx}(:, jndx)), 'filled');
                else          % Line and Line with Marker
                    ht(2) = line(T{indx}, imag(H{indx}(:, jndx)), 'parent', ax);
                end
            end
            
            set(ht, 'Visible', this.Visible);
            
            set(ht, 'Color', color);
            if any(type == [1 2]) % Line with Marker and Stem
                [m, f] = getmarker(this, nresps);
                set(ht(1), 'Marker', m{1}, 'MarkerFaceColor', f{1});
                if length(ht) == 2
                    set(ht(2), 'Marker', m{2}, 'MarkerFaceColor', f{2});
                end
            end
            h.line = [h.line ht];
        end
    end
    set(ax, 'NextPlot', np);
    
    % Setting the axes automatically updates the figures nextplot property.
    % So we need to reset that one too.
    set(this.FigureHandle, 'NextPlot', npfig);

    % Avoid setting the axis x limits to the same value - causes an error.
    xlimits = [T{1}(1), T{1}(end)];
    if ~isequal(xlimits(1), xlimits(2)) && ~any(isnan(xlimits)),
        set(ax(1),'xlim',xlimits);
    end
    
    set(h.line, 'Tag', getlinetag(this));
    hc = get(h.line, 'Children');
    if iscell(hc), hc = [hc{:}]; end
    set(hc, 'Tag', getlinetag(this));
end

set(this, 'Handles', h);

%-------------------------------------------------------------------
function setupaxes(this)

h = get(this, 'Handles');

h.axes = h.axes(end);

if ~ishandlefield(this, 'timecsmenu')
    h.timecsmenu = addtimecsmenu(this, get(h.axes, 'XLabel'));
end
if ~ishandlefield(this, 'plotcsmenu'),
    hc = get(h.axes, 'UIContextMenu');

    [hcs hmenu] = contextmenu(getparameter(this, 'plottype'), h.axes);

    % If there is already a context menu only store the new menus.
    if isempty(hc)
        h.plotcsmenu = hcs;
    else
        h.plotcsmenu = hmenu;
    end
end

set(this, 'Handles', h);

%-------------------------------------------------------------------
function setuplabels(this, units)

h = get(this, 'Handles');

% Get the xlabel from the time mode
if strcmpi(get(this, 'NormalizedFrequency'), 'on'),
    xlbl = 'Samples';
else
    xlbl = sprintf('Time (%s%s)', units, 'seconds'); %this.TimeUnits);
end

xlabel(h.axes, xlbl);
title(h.axes, xlate(get(this, 'Name')));
ylabel(h.axes, xlate('Amplitude'));

% [EOF]
