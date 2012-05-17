function str = filtertype_getstatefield(hObj)
%GETSTATEFIELD Return the field for the state

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 22:53:15 $

str = get(classhandle(hObj), 'Name');
str = {str(1:2)};

% [EOF]
