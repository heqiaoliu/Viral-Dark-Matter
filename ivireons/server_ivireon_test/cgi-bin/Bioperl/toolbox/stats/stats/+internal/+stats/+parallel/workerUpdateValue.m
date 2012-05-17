function workerUpdateValue(name,value)
%WORKERUPDATEVALUE updates the value associated with 'NAME' on a matlabpool worker 
%
%   WORKERUPDATEVALUE('NAME',VALUE) reassigns the value associated with 'NAME'
%   on a matlabpool worker to the new value VALUE.  The preexisting value 
%   will have been initialized on the worker by an invocation of 
%   DISTRIBUTETOPOOL('NAME',VALUES) on the client, and the value may have 
%   subsequently been modified by another invocation of
%   WORKERUPDATEVALUE('NAME',VALUE) on the same worker.
%
%   See also DISTRIBUTETOPOOL, RETRIEVEFROMPOOL, WORKERGETVALUE.  
%
%   WORKERUPDATEVALUE is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

    vstruct = internal.stats.parallel.statParallelStore(name);
    vstruct.value = value;
    internal.stats.parallel.statParallelStore(name,vstruct);
end
