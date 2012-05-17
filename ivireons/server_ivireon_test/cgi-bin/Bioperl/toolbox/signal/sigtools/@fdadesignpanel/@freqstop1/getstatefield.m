function str = getstatefield(hObj)
%GETSTATEFIELD Return fields names for the state structure

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 22:58:04 $

str    = filtertype_getstatefield(hObj);
str{2} = 'stop';

% [EOF]
