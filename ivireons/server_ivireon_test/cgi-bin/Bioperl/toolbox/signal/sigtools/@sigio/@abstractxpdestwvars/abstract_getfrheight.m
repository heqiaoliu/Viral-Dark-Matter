function hght = abstract_getfrheight(h)
%ABSTRACT_GETFRHEIGHT Get frame height.

% This should be a private method.

%   Author(s): P. Costa
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2003/04/11 18:44:10 $

sz = gui_sizes(h);
numVars = get(getcomponent(h, '-isa', 'siggui.labelsandvalues'), 'Maximum');

% Return a height for the destination options frame (since this frame
% contains a variable number of uis)
hght = (sz.uuvs+sz.uh)*numVars + 2*sz.vfus;

% [EOF]
