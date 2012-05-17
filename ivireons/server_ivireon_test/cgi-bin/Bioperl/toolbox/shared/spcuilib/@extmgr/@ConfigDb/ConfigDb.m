function this = ConfigDb(theName,varargin)
%ConfigDb Database of extension configuration objects.
%  ConfigDb(NAME) creates a configuration database object with name NAME.
%  If omitted, NAME is set to 'unnamed'.
%
%  ConfigDb(NAME,C1,C2...) adds extension configurations C1,C2,..., to
%  database.

% Copyright 2004-2006 The MathWorks, Inc.
% $Revision: 1.1.6.1 $ $Date: 2007/03/13 19:45:35 $

this = extmgr.ConfigDb;
if nargin>0
    this.Name = theName;
end
if nargin>1
    add(this,varargin{:});
end

l = [handle.listener(this, 'ObjectChildAdded',  @(hSrc, ev) childChanged(this)); ...
    handle.listener(this, 'ObjectChildRemoved', @(hSrc, ev) childChanged(this))];
set(this, 'ChildListeners', l);

% -------------------------------------------------------------------------
function childChanged(this)

hChild = allChild(this);
if isempty(hChild)
    this.EnableListener = [];
else
    this.EnableListener = handle.listener(hChild, hChild(1).findprop('Enable'), ...
        'PropertyPostSet', @(hSrc, ev) childEnableChanged(this, ev.AffectedObject));
end

% -------------------------------------------------------------------------
function childEnableChanged(this,hConfig)
%childEnableChanged React to a change in child Enabled status.
%  childEnableChanged(hConfigDb,hConfig) is called to signal a change in
%  Enable state in hConfig.  This method simply propagates the event, by
%  sending its own event with a copy of the originating hConfig in the
%  event payload.

if this.AllowConfigEnableChangedEvent

    % Throw an event to percolate the change-event "up the stack."
    send(this, 'ConfigEnableChanged', ...
        uiservices.EventData(this, 'ConfigEnableChanged', hConfig));
end


% [EOF]
