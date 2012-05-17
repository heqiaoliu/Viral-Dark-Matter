function hght = getfrheight(h)
%GETFRHEIGHT Get frame height.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.1 $  $Date: 2003/04/11 18:45:28 $

varsHght = abstract_getfrheight(h);
sz = gui_sizes(h);

% Adding addition height due to the overwrite checkbox
hght = varsHght + sz.uh + sz.uuvs;

% [EOF]
