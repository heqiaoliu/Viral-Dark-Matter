function setstate(hParent, s)
%SETSTATE Set the state of the object

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2.4.1 $  $Date: 2007/12/14 15:19:33 $

error(nargchk(2,2,nargin,'struct'));

sigcontainer_setstate(hParent, s);

% [EOF]
