function setstate(hObj,s)
%SETSTATE Set the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3.4.1 $  $Date: 2007/12/14 15:19:49 $

error(nargchk(2,2,nargin,'struct'));

siggui_setstate(hObj, s);

% [EOF]
