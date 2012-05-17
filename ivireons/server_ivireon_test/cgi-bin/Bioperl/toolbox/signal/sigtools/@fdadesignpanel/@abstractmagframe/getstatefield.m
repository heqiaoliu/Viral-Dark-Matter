function str = getstatefield(hObj)
%GETSTATEFIELD Return the strings for the state

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.3 $  $Date: 2002/04/14 22:54:17 $

str    = filtertype_getstatefield(hObj);
str{2} = 'passStop';

% [EOF]
