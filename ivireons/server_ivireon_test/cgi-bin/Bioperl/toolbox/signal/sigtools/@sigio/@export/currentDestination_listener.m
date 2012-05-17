function currentDestination_listener(this)
%CURRENTDESTINATION_LISTENER Listener to 'currentDestination'

%   Copyright 2008 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2008/08/01 12:25:49 $

% Set the popup string to match the current destination.
h = get(this, 'Handles');
idx = find(strcmp(this.CurrentDestination, this.AvailableDestinations));
if isempty(idx), idx = 1; end

set(h.xp2popup, 'Value', idx);

% [EOF]
