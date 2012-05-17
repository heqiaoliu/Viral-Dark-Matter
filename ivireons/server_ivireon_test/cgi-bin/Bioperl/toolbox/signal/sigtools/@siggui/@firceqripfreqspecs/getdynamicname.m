function Name = getdynamicname(h, eventData)
%GETDYNAMICNAME  Returns the name of the dynamic prperty

%   Copyright 1988-2002 The MathWorks, Inc.
%   $Revision: 1.2 $  $Date: 2002/04/14 23:04:30 $

% Get the handle 
p = get(h, 'Dynamic_Prop_Handles');

% extract name
Name = p.Name;

% [EOF]
