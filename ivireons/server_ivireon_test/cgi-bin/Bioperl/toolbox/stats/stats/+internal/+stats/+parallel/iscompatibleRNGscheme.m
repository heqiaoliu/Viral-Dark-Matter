function valid = iscompatibleRNGscheme(useParallel,RNGscheme)
%ISCOMPATIBLERNGSCHEME
%   ISCOMPATIBLERNGSCHEME is an internal utility for use by Statistics Toolbox
%   commands, and is not meant for general purpose use.  External users
%   should not rely on its functionality.
%
%   ISCOMPATIBLERNGSCHEME tests 
%   (1) whether an RNGscheme is valid with the current matlablpool state
%   (2) whether the RNGscheme is valid with the parallel computation flag.
%
%   In the case of (1) the RNGscheme is marked invalid if 
%   RNGscheme.streamsOnPool == true AND RNGscheme.streams is not the
%   same length as the matlabpool size.  In this case, we can determine 
%   that the RNGscheme is forever invalid because the matlabpool for which 
%   it was constructed has been closed (albeit perhaps replaced with a 
%   matlabpool of different size).  This test will NOT detect the case where
%   a matlabpool was reopened of the same size: that failure will occur 
%   when executable code tries to retrieve a value on a worker using 
%   RNGscheme.uuid as a retrieval key.
%
%   In the case of (2) the RNGscheme is invalid if
%   RNGscheme.streamsOnPool is true (in which case parallel computation is 
%   required), but useParallel is false.  It is also invalid if 
%   useParallel is true but the contents of RNGscheme don't support parallel 
%   computation (ie, ~useSubstream && ~useDefaultStream && ~streamsOnPool).
%   This occasion will arise if the RNGscheme was created for serial
%   computation, and given an explicit scalar RandStream object.
%   If either of these two tests fails, the function returns false;
%   however, the RNGscheme is not itself marked invalid, since it may
%   be valid with the opposite value of useParallel.
%
%   It is unnecessary to execute this function if it is known that the
%   context in which the RNGscheme was created has not changed when
%   it is now about to be used.  This may often be the case when the 
%   RNGscheme is created and used in the same toolbox command, and all
%   the code is property of a knowledgleable developer.
%   However, the validity check is wise in any kind of general purpose 
%   application or utility, and it will certainly be wise in any circumstance
%   where an RNGscheme structure is used across multiple toolbox commands.

%   Copyright 2010 The MathWorks, Inc.

valid = true;

if isempty(RNGscheme)
    % Parallel or serial computation w/o RNG specification is ruled valid.
    return
end

if ~RNGscheme.valid
    valid = false;
    error('stats:internal:iscompatibleRNGscheme:invalidRNGscheme', ...
        'The RNG scheme is no longer valid and should not be used, uuid=%s.', ...
            RNGscheme.uuid);
end

useSubstreams    = RNGscheme.useSubstreams;
streams          = RNGscheme.streams;
useDefaultStream = RNGscheme.useDefaultStream;
streamsOnPool    = RNGscheme.streamsOnPool;

if streamsOnPool && ~useParallel
    valid = false;
    error('stats:internal:iscompatibleRNGscheme:NeedsParallel', ...
        'The RNG scheme only works with parallel computation, uuid=%s', ...
            RNGscheme.uuid);
    return
end

if useParallel && ~useDefaultStream && ~useSubstreams 
    % We don't create an RNGscheme with multiple streams unless
    % a matlabpool is open at the time of creation.  Therefore, the creator
    % of the RNGscheme is licensed for PCT and the reference to "matlabpool"
    % should be valid.  No guarantees are made for an RNGscheme struct that
    % is saved and loaded back by a user without a PCT license.
    if length(streams)>1 && length(streams) ~= matlabpool('size')
        % This RNGscheme was created for a different matlabpool than the
        % one that is open now.
        RNGscheme.valid = false;
        valid = false;
        error('stats:internal:iscompatibleRNGscheme:NeedsParallel', ...
            'The RNG scheme is no longer valid, matlabpool has changed, uuid=%s', ...
                RNGscheme.uuid);
        return;
    end
end

end %-iscompatibleRNGscheme
