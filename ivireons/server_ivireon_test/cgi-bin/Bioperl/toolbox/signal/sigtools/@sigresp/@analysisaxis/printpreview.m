function printpreview(hObj)
%PRINTPREVIEW Print the filter response

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:37 $ 

hax = copyaxes(hObj);

hfig = get(hax(1), 'parent');

hWin_printprev = printpreview(hfig);
uiwait(hWin_printprev);
delete(hfig);

% [EOF]
