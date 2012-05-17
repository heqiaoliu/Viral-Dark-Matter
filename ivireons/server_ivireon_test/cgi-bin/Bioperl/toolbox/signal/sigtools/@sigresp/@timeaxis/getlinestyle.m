function lso = getlinestyle(hObj, varargin)
%GETLINESTYLE Returns the line color and style order

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:30:00 $

if strcmp(hObj.LineStyle, 'Stem'),
    lso = 'none';
else
    lso = '-';
end

% [EOF]