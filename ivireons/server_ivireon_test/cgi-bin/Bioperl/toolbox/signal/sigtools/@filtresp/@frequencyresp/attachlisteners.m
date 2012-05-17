function attachlisteners(this)
%ATTACHLISTENERS Attach listeners to properties for render updates.

%   Author(s): J. Schickler
%   Copyright 1988-2005 The MathWorks, Inc.
%   $Revision: 1.1.4.11 $  $Date: 2008/08/01 12:25:42 $

filtutils = this.FilterUtils;

l = [ ...
        handle.listener(this, this.findprop('DisplayMask'), ...
        'PropertyPostSet', @lcldisplaymask_listener) ...
        handle.listener(this.FilterUtils, filtutils.findprop('Filters'), ...
        'PropertyPostSet', @lclfilter_listener) ...
        handle.listener(this.FilterUtils, filtutils.findprop('ShowReference'), ...
        'PropertyPostSet', @lclshow_listener) ...
        handle.listener(this.FilterUtils, filtutils.findprop('PolyphaseView'), ...
        'PropertyPostSet', {@lclshow_listener, 'none'}) ...
        handle.listener(this.FilterUtils, filtutils.findprop('sosViewOpts'), ...
        'PropertyPostSet', @sosview_listener) ...
    ];

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

attachfilterlisteners(this);

% ----------------------------------------------------------
function attachfilterlisteners(this)

l = get(this, 'WhenRenderedListeners');
l = l(1:5);

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

% ----------------------------------------------------------
function sosview_listener(this, eventData)

Hd = get(this, 'Filters');
if length(Hd) == 1
    if isa(Hd.Filter, 'dfilt.abstractsos')
        lclshow_listener(this, eventData, 'x');
    end
end

% ----------------------------------------------------------
function lclshow_listener(this, eventData, limits)

if nargin < 3
    limits = 'both';
end

deletehandle(this, 'legend');

captureanddraw(this, limits);

% Make sure that we put up the legend after so that it is on top of the
% plotting axes.
updatelegend(this);


% ----------------------------------------------------------
function lcldisplaymask_listener(this, eventData)

updatemasks(this);

% ---------------------------------------------------------------------
function lclfilter_listener(this, eventData)

attachfilterlisteners(this);

lclshow_listener(this, eventData, 'none');

% ---------------------------------------------------------------------
function name_listener(this, eventData)

deletehandle(this, 'legend');
updatelegend(this);

% ---------------------------------------------------------------------
function fs_listener(this, eventData, varargin)

sendstatus(this, 'Computing Response ...');

set(this.WhenRenderedListeners, 'Enabled', 'Off');
this.NormalizedFrequency = 'off';
set(this.WhenRenderedListeners, 'Enabled', 'On');

captureanddraw(this, 'y');

sendstatus(this, 'Computing Response ... done');

% [EOF]
