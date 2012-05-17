function [useParallel, useSubstreams, streams] = extractParallelAndStreamFields( options )
%EXTRACTPARALLELANDSTREAMFIELDS processes parallel computation and stream options. 
%
%   EXTRACTPARALLELANDSTREAMFIELDS is an internal utility for use by 
%   Statistics Toolbox commands, and is not meant for general purpose use.  
%   External users should not rely on its functionality.

%   Copyright 2010 The MathWorks, Inc.


    useParallel     = strcmpi(statget(options,'UseParallel'), 'always');
    useSubstreams   = strcmpi(statget(options,'UseSubstreams'), 'always');
    streamArg       = statget(options,'Streams');
    
    % Repackage the Streams argument
    if isempty(streamArg)
        streams = {};
        if useSubstreams
            % If useSubstreams is true, reproducibility requires a single
            % stream to be used within any loop, even if many workers execute
            % iterations of the loop in parallel.  If no specific stream was
            % supplied in the 'options' argument, we take a snapshot
            % of the current default stream on the client, and use this as 
            % the basis for random number generation, even if the default
            % stream subsequently changes.
            streams{1} = RandStream.getDefaultStream;
        end
    elseif ~iscell(streamArg)   % we handle stream arguments with a cell array
        streams = {streamArg};
    else
        streams = streamArg;
    end
    
end %-extractParallelAndStreamFields
