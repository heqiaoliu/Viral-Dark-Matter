function out = pElementwiseOp( fcnName, doInfix, infixOp, varargin )
; %#ok undocumented

% Copyright 2010 The MathWorks, Inc.
% $Revision: 1.1.6.1.2.1 $   $Date: 2010/06/10 14:27:27 $

persistent cache
if isempty( cache )
    % Need a field in the cache so that we can assign into it later. Need a
    % name that can't possibly be a method.
    cache = struct( 'dummy', NaN );
end

[cache, thetree, thetable, thelocal] = iGetTreeAndTable( cache, fcnName, doInfix, infixOp, length( varargin ) );

inputSig = pFindSig( varargin{:} );
[thelocal, thetable] = pPtxFactoryInterface(thetree,inputSig,thelocal,thetable,varargin{:});

% If this worked, put things back in the cache
cache.(fcnName).KernelTable = thetable;
cache.(fcnName).KernelLocal = thelocal;

% Get the kernel and output type
localKernel = thetable.(inputSig).kernel;
outputType  = thetable.(inputSig).types;
outputComplexity = thetable.(inputSig).complexities;

% Output size matches the larger of the input args
[nmax, idxmax] = max( cellfun( @numel, varargin ) );
outSz = size( varargin{ idxmax } );

% Pre-allocate the return
if isequal( outputType{1}, 'logical' )
    out = parallel.gpu.GPUArray.hFalse( outSz );
else
    out = parallel.gpu.GPUArray.hZeros( outSz, outputType{1}, outputComplexity(1) );
end

% Calculate grid layout
localKernel = pGridLayout( localKernel, nmax );

out = feval( localKernel, out, varargin{:}, nmax );

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [cache, tree, table, local] = iGetTreeAndTable( cache, fcnName, doInfix, infixOp, nargs )
if isfield( cache, fcnName )
    entry = cache.(fcnName);
    tree  = entry.Tree;
    table = entry.KernelTable;
    local = entry.KernelLocal;
else
    
    % build variable names which are input arguments to the function
    arglist = sprintf( 'in%d, ', 1:nargs );
    % Strip final ", "
    arglist = arglist(1:end-2);
    
    % Build expression for function body
    if doInfix
        if nargs == 1
            expr = [infixOp, 'in1'];
        elseif nargs == 2
            expr = sprintf( 'in1 %s in2', infixOp );
        else
            % This would build 'in1 + in2 + in3' for the case where nargs==3 and infixOp=='+'
            expr = '';
            for ii=1:nargs-1
                expr = sprintf( '%sin%d %s ', expr, ii, infixOp );
            end
            expr = sprintf( '%sin%d', expr, nargs );
        end
    else
        expr = sprintf( '%s( %s )', fcnName, arglist );
    end
    
    % Build new cache entry for this function
    tree        = mtree( sprintf( 'function out = f(%s), out = %s; end', arglist, expr ) );
    table       = struct();
    local       = [];
    cache.(fcnName) = struct( 'Tree', tree, 'KernelTable', table, 'KernelLocal', local );
end
end
