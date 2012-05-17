function strs = dispstr(hWin)
%DISPSTR Returns the strings to display the window

%   Author(s): J. Schickler
%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/03/28 17:26:42 $

strs = sprintf('%g\n', generate(hWin));

% [EOF]
