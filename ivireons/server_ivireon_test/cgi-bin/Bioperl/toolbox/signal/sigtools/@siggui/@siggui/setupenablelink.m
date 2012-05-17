function setupenablelink(this, prop, varargin)
%SETUPENABLELINK   Setup an enable link between properties
%   SETUPENABLELINK(H, PROP, ENABVAL, LINKEDPROP1, LINKEDPROP2, etc.) Setup
%   an enable link between PROP and LINKEDPROP1, LINKEDPROP2, etc. so that
%   when PROP is set to ENABVALUE the linked properties UIControl's will
%   become disabled.  If PROP is 'yes' or 'on' the linked properties
%   UIControl's will be set to the enable state of the object.  ENABVALUE
%   can be a cell array of values.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2007/12/14 15:19:51 $

error(nargchk(4,inf,nargin,'struct'));

% Create a listener on the link property and pass the extra inputs.
l = handle.listener(this, this.findprop(prop), 'PropertyPostSet', ...
    {@lclenablelink_listener, varargin{:}});

set(l, 'CallbackTarget', this);
if ~isempty(this.WhenRenderedListeners),
    l = [l; this.WhenRenderedListeners(:)];
end
set(this, 'WhenRenderedListeners', l);

db = get(this, 'LinkDatabase');

newdb.prop = prop;
newdb.enabvalue = varargin{1};
newdb.linkedprops = varargin(2:end);

if isempty(db)
    db = newdb;
else
    db = [db, newdb];
end

set(this, 'LinkDataBase', db);

% Call the listener to make sure that the controls are linked up.
enablelink_listener(this, prop, varargin{:});

% -------------------------------------------------------------------------
function lclenablelink_listener(varargin)

enablelink_listener(varargin{:});

% [EOF]
