function [useParallel,RNGscheme,poolsz] = ...
    processParallelAndStreamOptions(opt, multipleStreams)
%PROCESSPARALLELANDSTREAMOPTIONS vets and organizes parallel and stream info.
% 
%   The command line arguments together define a set of ground rules as to 
%   how random number streams are to be utilized during a sequence of computations.
%   The input argument "opt" supplies the first three of the effective
%   arguments listed below.
%
%   The effective arguments are:
%
%      useParallel        boolean      Use parfor-loops in place
%                                      of for-loops (T/F).
%      useSubstreams      boolean      Use a separate Substream for each iterate
%                                      of the loop, both in for-loops and in
%                                      parfor-loops) (T/F).
%      streams            cell array   RandStream object(s), can be empty.
%      multipleStreams    boolean      Allow multiple user-supplied streams 
%                                      to be distributed to workers in a 
%                                      matlabpool (T/F).  Some toolbox commands
%                                      will support this paradigm, others not.
%
%   The return values are:
%
%      useParallel        boolean      Use parfor loops (T/F) vs for-loops.
%      RNGscheme          struct       Contains essential and convenience 
%                                      information defining the ground rules, 
%                                      or "scheme" for RNG use.
%      poolsz             integer      The size of the matlabpool to be used
%                                      for computation.  The value is zero if
%                                      no matlabpool is open or if useParallel
%                                      is false.
%
%   Contents of the RNGscheme struct are:
%      uuid               string       Unique identifier for the RNGscheme
%      useSubstreams      boolean      As described above
%      streams            cell array   As described above
%      valid              boolean      RNGscheme is currently valid 
%      useDefaultStream   boolean      RNGscheme uses the default RandStream
%      streamsOnPool      boolean      RNGscheme deploys multiple streams on the 
%                                      matlabpool
%
%   Notes:
%      1. The purpose of the field "uuid" is to support persistence of the
%         RNGscheme and allow multiple RNGschemes to be available at the
%         same time.
%      2. The value for "uuid" is derived using the command "tempname".
%         The documentation for "tempname" indicates that, when running
%         MATLAB without a JVM, the value for "uuid" is almost
%         certain to be unique, but the guarantee is not absolute.
%         We only require uniqueness for the lifetime of the MATLAB executable
%         in which the RNGscheme is created (this is the client executable
%         when there is a matlabpool open).
%      3. The field "valid" is intended to be writeable.  All other fields
%         should be immutable, once the RNGscheme struct has been initialized.
%      4. An RNGscheme will become invalid under the following conditions:
%         a. The RNGscheme was created for parallel computation with multiple 
%            streams and an open matlabpool, and that matlabpool has since 
%            been closed.
%         b. The RNGscheme was created for parallel computation with multiple 
%            streams and an open matlabpool.  Subsequently, serial computation
%            is requested, using the RNGscheme.
%         c. The RNGscheme was created without a matlabpool, but with a
%            RandStream object supplied in the command line argument "streams".
%            Subsequently, a matlabpool is open, and parallel computation
%            is attempted, using the RNGscheme.

%   Copyright 2010 The MathWorks, Inc.

if nargin<2
    multipleStreams = false;
end

[useParallel, useSubstreams, streams] = ...
    internal.stats.parallel.extractParallelAndStreamFields(opt);

% Check for valid Options parameters
[streamsOnPool,poolsz] = parforValidateStreamOptions(useParallel, ...
                                                     useSubstreams, ...
                                                     streams, ...
                                                     multipleStreams);

% Create and initialize the return argument
phonydir = ['phony' filesep];
uuid = regexprep(tempname('phony'),phonydir,'');
RNGscheme = struct('uuid',uuid, ...
                   'useSubstreams', useSubstreams, ...
                   'streams', [], ...
                   'valid', true, ...
                   'useDefaultStream', isempty(streams), ...
                   'streamsOnPool', streamsOnPool);
RNGscheme.streams = streams;

% If using multiple streams on a matlabpool, distribute one stream to
% each of the workers, retrievable via the key "uuid".
if streamsOnPool
    % A matlabpool is open.
    % The command line supplied multiple streams.
    % We need to fan the streams out to the matlabpool.
    internal.stats.parallel.distributeToPool(uuid,streams);
end

end   % of processParforOptions()

function [streamsOnPool,poolsz] = parforValidateStreamOptions( ...
    useParallel, useSubstreams, streams, multipleStreams ) 
%
%   This is a utility function used to support statistics functions that may
%   employ parfor-loops. The function checks that options affecting random 
%   number usage are valid in the current execution environment.
%   Invalid combinations of options cause an exception to be thrown.
%   The options to be validated are:
%
%      useParallel      boolean       Use parfor-loops in place
%                                     of for-loops (T/F).
%      useSubstreams    boolean       Use a separate Substream for each iterate
%                                     of the loop, both in for-loops and in
%                                     parfor-loops) (T/F).
%      streams          cell array    RandStream object(s), can be empty.
%      multipleStreams  boolean       Allow multiple user-supplied streams 
%                                     to be distributed to workers in a 
%                                     matlabpool (T/F).  Some toolbox commands
%                                     will support this paradigm, others not.
%
%   The return values are:
%
%      streamsOnPool    boolean       Multiple user-supplied streams are to be
%                                     used by workers in the matlabpool (T/F).
%      poolsz           integer       The size of the matlabpool to be used
%                                     for computation.  The value is zero if
%                                     no matlabpool is open or if useParallel
%                                     is false.
%
%   Factors determining validity are:
%
%      (1) Availability of the Parallel Computing Toolbox (PCT)
%          (ie, licensing and installation)
%      (2) Presence or absence of an open matlabpool
%      (3) Statistics Toolbox guidelines for random number stream usage
%          in serial and parallel contexts.
%
%   The rules determining validity are:
%
%      (1) useParallel (ie, parfor) is valid w/wo PCT
%      (2) useParallel (ie, parfor) is valid w/wo a matlabpool
%          (parfor loops run in serial on the client if no matlabpool)
%      (3) streams must be empty or scalar unless all of the following hold
%             useParallel     is true
%             a matlabpool    is open
%             multipleStreams is true
%             useSubstreams   is false
%          in which case
%             length(streams) must equal the matlabpool size
%          and
%             we return streamsOnPool = true
%             (otherwise, streamsOnPool = false)
%      (4) If useSubstreams is true the stream type must support Substreams.
%          The calling convention of this function is that if useSubstreams
%          is true, then the streams argument cannot be empty; a scalar
%          value must be supplied.

streamsOnPool = false;

% devolve to serial if no parallel environment
if useParallel
    usePool = true;
    if ~isempty(ver('distcomp'))
        % PCT installed and have license
        poolsz = matlabpool('size');
        if poolsz<1
            % No matlabpool open
            usePool = false;
            warning('stats:parallel:NoMatlabpool', ...
                'Using parfor without matlabpool.');
        end
    else
        % No PCT
        poolsz = 0;
        usePool = false;
        if ~isempty(streams) && length(streams)>1
            MEboot = MException('stats:parallel:BadOptions:Streams', ...
                'Cannot use multiple streams if no Parallel Computing Toolbox.');
            throw(MEboot);
        end
    end
else
    usePool = false;
    poolsz = 0;
end

if useSubstreams
    % Can only use a single stream, regardless of serial/parallel, 
    % number of workers.
    if length(streams)>1
        error('stats:internal:processParallelAndStreamOptions:MultipleStreams', ...  
            '''Streams'' parameter must be scalar if UseSubstreams is selected.');
    end
    % Make sure that this RandStream type supports Substreams.
    % Do so by seeing if it is possible to change the Substream property
    % on a stream of the same type.
    s = streams{1};
    sisterStream = RandStream(s.Type);
    try
        sisterStream.Substream = sisterStream.Substream+1;
    catch ME
        clear sisterStream;
        throw(ME);
    end
    clear sisterStream
    return
end

if ~isempty(streams)
    % A 'Streams' parameter was supplied.
    if length(streams)>1
        if ~multipleStreams
            error('stats:internal:processParallelAndStreamOptions:MultipleStreams', ...
                'Multiple streams are not supported by the function that you called.');
        elseif ~usePool
            error('stats:internal:processParallelAndStreamOptions:MultipleStreams', ...
                '''Streams'' parameter must be scalar if serial computation.');
        end
    end
    
    if usePool && multipleStreams
        % There is an open matlabpool and the function supports
        % distributing multiple streams to the pool.
        % Enforce the condition that the number of
        % supplied RandStream objects must match the matlabpool size.
        if length(streams) ~= poolsz
            error('stats:internal:processParallelAndStreamOptions:MultipleStreams', ...
                'Number of streams must match matlabpool size.');
        end
        % This variable records that Streams should be distributed to
        % the matlabpool, one stream for each worker.
        streamsOnPool = true;
    end
end

end % of parforValidateStreamOptions()
