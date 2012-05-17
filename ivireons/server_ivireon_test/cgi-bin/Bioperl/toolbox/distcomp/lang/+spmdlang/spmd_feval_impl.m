function spmd_feval_impl( bodyFcn, assignOutFcn, getOutFcn, unpackInFcn, initialOutCell, inputCell, varargin )
%SPMD_FEVAL_IMPL - support for SPMD block
    
% Copyright 2008 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2008/11/04 21:16:39 $


    resSet = spmdlang.ResourceSetMgr.chooseResourceSet( inputCell, varargin{:} );

    % the resource set knows how to execute a block.
    blockExecutor = resSet.buildBlockExecutor( bodyFcn, assignOutFcn, getOutFcn, ...
                                               unpackInFcn, initialOutCell );
    
    blockExecutor.initiateComputation();
    
    while ~blockExecutor.isComputationComplete()
        % isComputationComplete will block for a while waiting for completion
    end

    % Give the block executor the opportunity to throw any errors detected on
    % the labs. The block executor is free to throw such errors at any other
    % time, but this is the last opportunity.
    try
        blockExecutor.throwBlockExceptions();
    catch E
        throwAsCaller( E );
    end
    
    dispose( blockExecutor );
    
    % NB outputs assigned for caller in "delete" of blockExecutor.
end
