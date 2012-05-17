function enable_listener(this, varargin)
%ENABLE_LISTENER   Listener to the Enable property.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:26:35 $

hall = get(this, 'Handles');

set(this, 'Handles', rmfield(hall, 'custom'));
dialog_enable_listener(this, varargin{:});
set(this, 'Handles', hall);

newselection_listener(this);

% [EOF]
