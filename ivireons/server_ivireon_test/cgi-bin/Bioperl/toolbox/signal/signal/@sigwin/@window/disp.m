function disp(hWIN)
%DISP Display a window object

%   Author(s): V.Pellissier
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.3.4.2 $  $Date: 2004/04/13 00:16:54 $

disp(reorderstructure(get(hWIN), 'Name'));

% [EOF]
