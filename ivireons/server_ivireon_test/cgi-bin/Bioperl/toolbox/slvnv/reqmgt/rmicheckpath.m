function [ResultDescription, ResultDetails] = rmicheckpath(system)

% Copyright 2006-2010 The MathWorks, Inc.

    [ResultDescription, ResultDetails] = rmi.mdlAdvCheck('path', system);
end
