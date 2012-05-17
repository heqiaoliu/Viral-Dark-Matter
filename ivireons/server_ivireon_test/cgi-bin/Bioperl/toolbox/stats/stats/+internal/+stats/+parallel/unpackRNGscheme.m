function [streamsOnPool, useSubstreams, S, uuid] = unpackRNGscheme(RNGscheme)
%UNPACKRNGSCHEME extracts random stream info for use by Stats Toolbox commands.
%
%   UNPACKRNGSCHEME is an internal utility for use by
%   Statistics Toolbox commands, and is not meant for general purpose use.
%   External users should not rely on its functionality.
%

%   Copyright 2010 The MathWorks, Inc.

if ~isempty(RNGscheme)
    % RNGscheme fields
    uuid             = RNGscheme.uuid;
    useSubstreams    = RNGscheme.useSubstreams;
    streams          = RNGscheme.streams;
    useDefaultStream = RNGscheme.useDefaultStream;
    streamsOnPool    = RNGscheme.streamsOnPool;
    
    % Derived quantities
    if ~useDefaultStream && ~streamsOnPool
        % Serial computation with an explicitly supplied stream,
        % and/or if using Substreams.
        S = streams{1};
    else
        S = [];
    end
else
    % RNGscheme fields
    uuid = [];
    useSubstreams = false;
    streamsOnPool = false;
    
    % Derived quantities
    S = [];
end

