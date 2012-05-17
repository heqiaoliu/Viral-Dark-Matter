function twoanalyses_attachlisteners(this)
%TWOANALYSES_ATTACHLISTENERS   

%   Author(s): J. Schickler
%   Copyright 1988-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.5 $  $Date: 2009/01/05 18:01:59 $

l = [ ...
        handle.listener(this, this.findprop('Analyses'), ...
        'PropertyPreSet', @preresponses_listener); ...
        handle.listener(this, this.findprop('Analyses'), ...
        'PropertyPostSet', @postresponses_listener); ...
    ];
set(l, 'CallbackTarget', this);
set(this, 'WhenRenderedListeners', l);

% ---------------------------------------------------------
function preresponses_listener(this, eventData)

h = get(this, 'Handles');
if isfield(h, 'legend') && ishghandle(h.legend),
    delete(h.legend);
end

oldresps = get(this, 'Analyses');
for indx = 1:length(oldresps),
    unrender(oldresps(indx));
end

% ---------------------------------------------------------
function postresponses_listener(this, eventData)

% Redraw the Analyses
thisdraw(this);

% We have to call updategrid ourselves because this is normally taken care
% of by THISRENDER at the USESAXES level.
updategrid(this);

% We must call updatelegend because the preset delete it.
updatelegend(this);

fixlisteners(this);

send(this, 'NewPlot', handle.EventData(this, 'NewPlot'));

% ---------------------------------------------------------
function fixlisteners(this)

l = get(this, 'UsesAxes_WhenRenderedListeners');
l(1) = handle.listener(getparameter(this), 'NewValue', @lclparameter_listener);
set(l(1), 'CallbackTarget', this);

set(this, 'UsesAxes_WhenRenderedListeners', l);

% ---------------------------------------------------------
function lclparameter_listener(this, eventData)

thisdraw(this);

send(this, 'NewPlot', handle.EventData(this, 'NewPlot'));


% [EOF]
