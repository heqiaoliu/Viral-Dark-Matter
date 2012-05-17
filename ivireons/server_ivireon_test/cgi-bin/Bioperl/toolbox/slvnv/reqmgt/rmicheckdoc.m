function [ResultDescription, ResultDetails] = rmicheckdoc(system)

% Copyright 2006-2010 The MathWorks, Inc.

    [ResultDescription, ResultDetails] = rmi.mdlAdvCheck('doc', system);
end
