function attachlisteners(this)
%ATTACHLISTENERS   Attach the listeners to help with redrawing.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.6 $  $Date: 2004/07/14 06:45:21 $

filtutils = get(this, 'FilterUtils');

l = [ ...
        handle.listener(this.FilterUtils, filtutils.findprop('Filters'), ...
        'PropertyPostSet', @lclfilter_listener); ...
        handle.listener(this.FilterUtils, [filtutils.findprop('ShowReference'), ...
        filtutils.findprop('PolyphaseView')], 'PropertyPostSet', @lclsrr_listener); ...
        handle.listener(this.FilterUtils, filtutils.findprop('SOSViewOpts'), ...
        'PropertyPostSet', @sosview_listener); ...
    ];

set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

attachfilterlisteners(this);

% ----------------------------------------------------------
function attachfilterlisteners(this)

l = get(this, 'WhenRenderedListeners');
l = l(1:3);

Hd = get(this, 'Filters');
if ~isempty(Hd),
    l = [ ...
            l(:); ...
            handle.listener(Hd, 'NewFs', @fs_listener); ...
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
        lclsrr_listener(this, eventData);
    end
end

% ----------------------------------------------------------
function lclsrr_listener(this, eventData)

deletehandle(this, 'legend');

captureanddraw(this);

% Make sure that we put up the legend after so that it is on top of the
% plotting axes.
updatelegend(this);

% ---------------------------------------------------------------------
function lclfilter_listener(this, eventData, varargin)

attachfilterlisteners(this);

lclsrr_listener(this);

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

set(this.WhenRenderedListeners, 'Enabled', 'Off');
this.NormalizedFrequency = 'off';
set(this.WhenRenderedListeners, 'Enabled', 'On');

captureanddraw(this, 'y');
sendstatus(this, 'Computing Response ... done');

% [EOF]
