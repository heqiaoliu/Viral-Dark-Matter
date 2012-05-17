function attachlisteners(this)
%ATTACHLISTENERS   

%   Author(s): J. Schickler
%   Copyright 2006-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2009/01/05 18:00:03 $

filtutils = get(this, 'FilterUtils');

l = [ ...
        handle.listener(this, this.findprop('DisplayMask'), ...
        'PropertyPostSet', @lcldisplaymask_listener) ...
        handle.listener(filtutils, filtutils.findprop('Filters'), ...
        'PropertyPostSet', @lclfilter_listener) ...
        handle.listener(filtutils, filtutils.findprop('sosViewOpts'), ...
        'PropertyPostSet', @sosview_listener) ...
        handle.listener(this.FilterUtils, ...
        [filtutils.findprop('PolyphaseView') filtutils.findprop('ShowReference')], ...
        'PropertyPostSet', @lclshow_listener) ...
        ];

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

attachfilterlisteners(this);

% ----------------------------------------------------------
function lcldisplaymask_listener(this, eventData)

updatemasks(this);

% ----------------------------------------------------------
function sosview_listener(this, eventData)

Hd = get(this, 'Filters');
if length(Hd) == 1
    if isa(Hd.Filter, 'dfilt.abstractsos')
        lclshow_listener(this, eventData);
    end
end

% ----------------------------------------------------------
function lclshow_listener(this, eventData)

deletehandle(this, 'legend');

captureanddraw(this, 'both');

% Make sure that we put up the legend after so that it is on top of the
% plotting axes.
updatelegend(this);

% ----------------------------------------------------------
function attachfilterlisteners(this)

l = get(this, 'WhenRenderedListeners');
l = l(1:4);

Hd = get(this, 'Filters');
if ~isempty(Hd),
    l = [ ...
            l ...
            handle.listener(Hd, 'NewFs', @fs_listener) ...
            handle.listener(Hd, Hd(1).findprop('Name'), ...
            'PropertyPostSet', @name_listener) ...
        ];
end
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% ---------------------------------------------------------------------
function lclfilter_listener(this, eventData, varargin)

attachfilterlisteners(this);

% When the filters change the legend may be invalid.  Delete it to force an
% update.
h = get(this, 'Handles');
if isfield(h, 'legend') && ishghandle(h.legend), delete(h.legend); end

draw(this, varargin{:});

% Make sure that we put up the legend after so that it is on top of the
% plotting axes.
updatelegend(this);

% ---------------------------------------------------------------------
function name_listener(this, eventData)

if ishandlefield(this, 'legend'),
    h = get(this, 'Handles');
    delete(h.legend);
end

updatelegend(this);

% ---------------------------------------------------------------------
function fs_listener(this, eventData, varargin)

sendstatus(this, 'Computing Response ...');
draw(this, varargin{:});
sendstatus(this, 'Computing Response ... done');

% [EOF]
