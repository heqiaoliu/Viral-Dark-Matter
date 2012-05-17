function [ResultDescription, ResultDetails] = rmicheckid(system)

% Copyright 2006-2010 The MathWorks, Inc.

    [ResultDescription, ResultDetails] = rmi.mdlAdvCheck('id', system);
end
