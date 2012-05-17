function setstate(this, state)
%SETSTATE   Set the state.

%   Author(s): J. Schickler
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2004/03/15 22:30:13 $

this.Data = state;
this.SelectedFilters = [];

send(this, 'NewData');

% [EOF]
