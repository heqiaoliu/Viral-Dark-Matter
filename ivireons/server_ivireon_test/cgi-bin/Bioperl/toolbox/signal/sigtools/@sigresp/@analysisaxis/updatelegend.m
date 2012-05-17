function updatelegend(this, varargin)
%UPDATELEGEND Update the legend

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.10 $  $Date: 2009/01/05 18:01:52 $

% This should be private.

% We cannot reliably update the legend when the display is invisible
% because the "best" option does not work when the lines are not visible.
if strcmpi(this.Visible, 'Off')
    return;
end

h = get(this, 'Handles');

if strcmpi(this.Legend, 'On')

    if ~isempty(getline(this)),

        % Remove the old legend.
        if isfield(h, 'legend') && ishghandle(h.legend)
            rmappdata(h.legend, 'OBD_Listener');
            delete(h.legend);
        end

        w = warning('off', 'MATLAB:legend:useMethod');

        [wstr, wid] = lastwarn('');

        % Get the legend strings from the object.  The object should know how
        % many lines were required, so this should be a cell array of strings
        % of length equal to the output of GETLINE.
        pos = get(this, 'LegendPosition');
        if ischar(pos)
            pos = {'Location', pos};
        else
            pos = {pos};
        end
        set(getline(this), 'Visible','on');
        hax = gettopaxes(this);
        axes_position = get(hax, 'Position');
        h.legend = legend(gettopaxes(this), getline(this), getlegendstrings(this), pos{:});
        set(hax, 'Position', axes_position);

        l = uiservices.addlistener(h.legend, 'ObjectBeingDestroyed', @(h,ev) onLegendBeingDeleted(this));
        setappdata(h.legend, 'OBD_Listener', l);
        setappdata(h.legend, 'zoomable', 'off');

        lastwarn(wstr, wid);
        warning(w);

        % Make sure that the color matches the bottom axes.
        set(h.legend, 'HandleVisibility', 'Callback', ...
            'Color', get(getbottomaxes(this), 'Color'), 'Visible', this.Visible);

        set(this, 'Handles', h);
    end
elseif ishandlefield(this, 'legend')
    delete(h.legend);
end

% -------------------------------------------------------------------------
function onLegendBeingDeleted(this)

% Because of the order in which HG deletes objects, "this" can be deleted
% before the legend, causing errors.  Avoid these by verifying the "this"
% is still a valid object.
if isa(this, 'sigresp.analysisaxis')
    set(this, 'Legend', 'Off');
end

% [EOF]
