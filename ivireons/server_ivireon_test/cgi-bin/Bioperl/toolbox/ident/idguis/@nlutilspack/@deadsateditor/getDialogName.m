function name = getDialogName(this)
%return a name of the dialog

% Copyright 2005-2006 The MathWorks, Inc.
% $Revision: 1.1.8.1 $ $Date: 2006/12/27 20:54:50 $

if this.isSat
    name = 'Saturation Limits';
else
    name = 'Dead Zone Limits';
end
