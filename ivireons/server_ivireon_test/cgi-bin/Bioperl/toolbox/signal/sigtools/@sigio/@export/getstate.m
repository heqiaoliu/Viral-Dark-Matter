function s = getstate(this)
%GETSTATE Get the state of the object.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:44:44 $

s = sigcontainer_getstate(this);
s = rmfield(s, 'Data');
s = rmfield(s, 'Destination');

% [EOF]
