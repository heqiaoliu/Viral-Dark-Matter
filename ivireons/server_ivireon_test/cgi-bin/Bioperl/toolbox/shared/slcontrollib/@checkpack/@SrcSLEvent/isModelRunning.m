function running = isModelRunning(this)
%ISMODELRUNNING True if the model is simulating.

%   Copyright 2010 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2010/03/26 17:51:06 $

running = false;
if strcmpi('running',getSimState(this))
    running = true;
end
end

