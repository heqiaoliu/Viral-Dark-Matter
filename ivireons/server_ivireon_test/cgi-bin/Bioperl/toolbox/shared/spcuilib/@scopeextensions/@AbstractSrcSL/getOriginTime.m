function originTime = getOriginTime(this)
%GETORIGINTIME Get the originTime.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:49:12 $

m = getParentModel(this);

try
    
    workspace = m.ModelWorkspace;
    
    data = workspace.data;
    
    bringUpVariables(data);
    originTime = defineOriginTime(m.StartTime);
    
catch ME %#ok<NASGU>
    originTime = evalin('base', m.StartTime);
end

% -------------------------------------------------------------------------
function bringUpVariables(data)

for indx = 1:numel(data)
    assignin('caller', data(indx).Name, data(indx).Value); 
end

% -------------------------------------------------------------------------
function originTime = defineOriginTime(mStartTime)

originTime = evalin('caller', mStartTime);

% [EOF]
