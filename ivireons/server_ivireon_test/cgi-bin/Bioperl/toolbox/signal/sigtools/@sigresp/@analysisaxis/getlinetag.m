function str = getlinetag(hObj)
%GETLINETAG Returns the tag used for the line

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:30 $

str = sprintf('%s_line', get(classhandle(hObj), 'name'));

% [EOF]
