function reconcileStreamsAfterLoop(RNGscheme,initialSubstreamOffset,niter)
%RECONCILESTREAMSAFTERLOOP updates random streams state after a parallelized loop.
%
%   RECONCILESTREAMSAFTERLOOP is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.

    streams = RNGscheme.streams;
    if RNGscheme.useSubstreams
        streams{1}.Substream = initialSubstreamOffset + niter;
    else if RNGscheme.streamsOnPool
        poolStreams = internal.stats.parallel.retrieveFromPool(RNGscheme.uuid);
        for i=1:length(streams)
            streams{i}.State = poolStreams{i}.State;
        end
    end
end
