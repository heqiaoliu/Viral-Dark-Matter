function aClose = action(hFs)
%ACTION Perform the action of the fsdialog box

%   Author(s): J. Schickler
%   Copyright 1988-2003 The MathWorks, Inc.
%   $Revision: 1.6.4.2 $  $Date: 2004/04/13 00:23:46 $

% If getfs errors then the user entered an invalid variable.
getfs(hFs);

% Send the NewFs event
send(hFs, 'NewFs', handle.EventData(hFs, 'NewFs'));
aClose = true;

% [EOF]
