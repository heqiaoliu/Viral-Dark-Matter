function visible_listener(this, varargin)
%VISIBLE_LISTENER   Listener to the Visible property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2004/04/13 00:22:04 $

hall = get(this, 'Handles');
set(this, 'Handles', rmfield(hall, 'checkbox'));

sigcontainer_visible_listener(this, varargin{:});

set(this, 'Handles', hall);

labels_listener(this);

% [EOF]
