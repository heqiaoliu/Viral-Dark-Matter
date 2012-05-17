function strs = whichframes(h)
%WHICHFRAMES  Return constructors of frames needed for FDATool.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.2.4.2 $  $Date: 2004/04/13 00:01:23 $

c = class(h);

strs.constructor = ['fdadesignpanel' c(findstr(c, '.'):end)];
strs.setops      = {};

% [EOF]
