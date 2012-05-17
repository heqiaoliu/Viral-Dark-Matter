function b = showref(this)
%SHOWREF   Returns true if the reference should be shown.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:20:10 $

b = strcmpi(this.ShowReference, 'On');

% [EOF]
