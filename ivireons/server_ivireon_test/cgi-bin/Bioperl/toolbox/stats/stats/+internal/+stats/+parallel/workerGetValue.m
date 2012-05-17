function v = workerGetValue(name)
%WORKERGETVALUE retrieves the value associated with 'NAME' on a matlabpool worker 
%
%   WORKERGETVALUE('NAME') retrieves the value associated with 'NAME' on a 
%   matlabpool worker.  The value will have been initialized on the worker
%   by an invocation of DISTRIBUTETOPOOL('NAME',VALUES) on the client, and
%   the value may have subsequently been modified by an invocation of
%   WORKERUPDATEVALUE('NAME',VALUE) on the same worker.
%
%   See also DISTRIBUTETOPOOL, RETRIEVEFROMPOOL, WORKERUPDATEVALUE.  
%
%   WORKERGETVALUE is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

    vstruct = internal.stats.parallel.statParallelStore(name);
    v = vstruct.value;
end

