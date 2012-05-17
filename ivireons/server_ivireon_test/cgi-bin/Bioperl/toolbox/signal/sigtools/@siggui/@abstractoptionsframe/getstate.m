function s = getstate(h)
%GETSTATE Get the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:10:11 $

s = siggui_getstate(h);
s = rmfield(s, 'Name');

% [EOF]
