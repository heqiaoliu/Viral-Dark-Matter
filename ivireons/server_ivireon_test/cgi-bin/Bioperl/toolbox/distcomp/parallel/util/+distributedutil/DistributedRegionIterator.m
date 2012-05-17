% DistributedRegionIterator - helper class for DSAVE and DLOAD
%   This class understands how to chunk through a distributed array during
%   either loading or saving by pieces.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/10/12 17:28:20 $

classdef ( Sealed = true, Hidden ) DistributedRegionIterator < handle
    
    properties
        %% Properties needed to iterate, set during construction and then not modified.

        % Dimension that we're going to chunk through
        DimToChunk
        % Number of elements in that dimension we'll take at a time
        NumPerChunk
        % How many chunks we need to take to traverse the dimension
        NumChunks
        
        % Full size of the array
        FullSize
        
        % Remaining elements of size in dimensions higher than the one we're
        % chunking through (might be empty)
        HighDimSize
       
        %% How far we are through iterating
        CurrChunk      = 1;
        CurrHighDimIdx = 1; 
    end
    
    methods
        function obj = DistributedRegionIterator( D )
        % Given a distributed object, create a region iterator
            fullBytes  = hGetRemoteBytes( D );
            fullNumel  = numel( D );
            fullSz     = size( D );
            bytesPerEl = fullBytes / fullNumel;
            chunkBytes = distributedutil.DsaveDloadParser.blockSizeBytes();
            
            % Most of the decisions about the chunking are taken in this subfunction
            [chunkInDim, numPerChunk, numChunks] = ...
                iChooseDistributedChunking( fullSz, bytesPerEl, chunkBytes );

            obj.DimToChunk  = chunkInDim;
            obj.NumPerChunk = numPerChunk;
            obj.NumChunks   = numChunks;

            obj.FullSize    = fullSz;
            obj.HighDimSize = fullSz( (chunkInDim + 1):end );
        end
        
        function region = nextRegion( obj )
        % Return the next region to operate on as a start/end structure.
            if ~obj.hasMoreRegions()
                error( 'distcomp:regioniterator:NoMoreRegions', ...
                       'Internal error: no more regions' );
            end
            
            % Extract the current region, then increment the indices for next time.
            highDimSubs = iChooseHigherDimSubs( obj.HighDimSize, obj.CurrHighDimIdx );

            startPointInChunkDim = 1 + ( (obj.CurrChunk-1) * obj.NumPerChunk );
            % end point is start point + numToChunk, but don't exceed full size.
            endPointInChunkDim = min( (startPointInChunkDim + obj.NumPerChunk - 1), ...
                                      obj.FullSize( obj.DimToChunk ) );

            % Build the region structure.
            region = struct( 'start', [ ones( obj.DimToChunk - 1, 1 ); ... % 1:end in lower dims
                                startPointInChunkDim; ...              % e:f in chunk dim 
                                highDimSubs ], ...                     % 1 element in higher dims 
                             'end', [ obj.FullSize( 1:(obj.DimToChunk-1) ).'; ...
                                endPointInChunkDim; ...
                                highDimSubs ] );
            
            % Move on to the next region
            obj.CurrChunk = obj.CurrChunk + 1;
            if obj.CurrChunk > obj.NumChunks
                obj.CurrChunk      = 1;
                obj.CurrHighDimIdx = obj.CurrHighDimIdx + 1;
            end
        end
        
        function tf = hasMoreRegions( obj )
            tf = obj.CurrHighDimIdx <= prod( obj.HighDimSize );
        end
        
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Here, we choose the way that we're going to chunk through the global
% array. Pick a chunk dimension so that we pick all of the lower dimensions,
% some number from that dimension, and 1 element in each higher
% dimension. Pick this to match desiredChunkBytes.
% 
% Imagine a matrix of size [100 100 100 100], where bytesPerEl and
% desiredChunkBytes are such that we want to pick about 200000
% elements. This means that we should chunk in the third dimension, and
% choose 20 elements at a time in that dimension. This function would return
% [3, 20, 5] - i.e. it takes 5 lots of 20 to span the third dimension.
function [chunkInDim, numPerChunk, numChunks] = ...
    iChooseDistributedChunking( fullSz, bytesPerEl, desiredBytesPerChunk )

    cumElsPerDim      = cumprod( fullSz );
    targetElsPerChunk = desiredBytesPerChunk / bytesPerEl;
    chunkInDim        = find( cumElsPerDim > targetElsPerChunk, 1, 'first' );

    if isempty( chunkInDim )
        % No chunking required.
        chunkInDim  = length( fullSz );
        numPerChunk = fullSz(end);
        numChunks   = 1;
    else
        % How many bytes would we take by selecting : in all dimensions prior to
        % chunkInDim, and 1 element in chunkInDim. (NB: prod([]) == 1)
        totalElsPerElInChunkDim = prod( fullSz(1:chunkInDim-1) );
        
        % How many should we take at a time in that dimension
        numPerChunk             = ceil( targetElsPerChunk / totalElsPerElInChunkDim );
        
        % How many chunks does it take to traverse the chunk dimension
        numChunks               = ceil( fullSz( chunkInDim ) / numPerChunk );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Given a linear index into the dimensions higher than the one we're
% chunking over, and the size of only the higher dimensions, return a column
% vector the same length as highDimSz to append to the region
function highDimSubs = iChooseHigherDimSubs( highDimSz, highDimIdx )

    if isempty( highDimSz )                 % must be chunking in the last dimension
        highDimSubs = zeros( 0, 1 );
    elseif isscalar( highDimSz )            % only one trailing dimension
        highDimSubs = highDimIdx;
    else                                    % multiple trailing dimensions over which to chunk
        subsCell = cell( 1, length( highDimSz ) );
        [subsCell{:}] = ind2sub( highDimSz, highDimIdx );
        highDimSubs = vertcat( subsCell{:} );
    end
end
