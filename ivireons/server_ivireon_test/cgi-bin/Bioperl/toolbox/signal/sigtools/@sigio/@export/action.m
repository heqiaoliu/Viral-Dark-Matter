function aClose = action(this)
%ACTION Perform the action of the export dialog

%   Author(s): P. Costa
%   Copyright 1988-2004 The MathWorks, Inc.
%   $Revision: 1.1.8.4 $  $Date: 2004/12/26 22:22:46 $

hCD = get(this,'Destination');
aClose = action(hCD);

if isrendered(this)
    set(this, 'Visible', 'Off');
end

% [EOF]
