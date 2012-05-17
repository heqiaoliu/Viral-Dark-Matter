function reorderinputs = getreorderinputs(this)
%GETREORDERINPUTS   Returns the reorderinputs as a cell array.

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2004/04/13 00:26:26 $

reorderinputs = {get(this, 'ReorderType')};

if strcmpi(reorderinputs{1}, 'custom'),
    hc = getcomponent(this, 'custom');
    reorderinputs = getreorderinputs(hc);
end

% [EOF]
