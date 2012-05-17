function print(hObj)
%PRINT Print the response

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:28:36 $ 

hax = copyaxes(hObj);

hfig = get(hObj, 'FigureHandle');
hfig_print = get(hax(1), 'Parent');

setptr(hfig,'watch');        % Set mouse cursor to watch.
printdlg(hfig_print);
setptr(hfig,'arrow');        % Reset mouse pointer.
close(hfig_print);

% [EOF]
