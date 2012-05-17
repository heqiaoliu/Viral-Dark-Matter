function stream = prepareStream(iter,initialSubstream,S,usePool,useSubstreams,uuid)
%PREPARESTREAM readies the random stream object STREAM for a for/parfor iteration.
%
%   PREPARESTREAM gets the STREAM to use if the code is running on a matlabpool,
%   and there are multiple streams on different workers. It positions the 
%   Substream property if separate substreams are being used for each iterate.
%
%   PREPARESTREAM is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

if usePool
    S = internal.stats.parallel.workerGetValue(uuid);
end
if useSubstreams
    S.Substream = iter + initialSubstream - 1;
end
stream = S;
end %-prepareStream

