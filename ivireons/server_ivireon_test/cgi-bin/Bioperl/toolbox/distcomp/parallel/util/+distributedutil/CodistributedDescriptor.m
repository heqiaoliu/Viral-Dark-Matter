% This class represents the local part layout of tensor-product style
% distribution schemes. This is only valid for cases where the local parts
% are packed plain-old-data arrays.

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/04/15 23:00:42 $
classdef CodistributedDescriptor
    properties ( Access = public )
        NumRegions      % The number of distinct regions
        LabOwningRegion % A vector length NumRegions
        
        ArrayNDims      % The number of dimensions of the global array
        LPNDims         % Number of dimensions of the local parts

        % Note that the number of dimensions stored here is the number of dimensions
        % required to index the local part, and that this might be higher
        % than the global-size dimensionality of the array. It is assumed
        % any actual index operations into the local part will resolve this
        % discrepancy. (This is certainly the case for e.g. a 1d
        % distribution scheme with a distribution dimension which is higher
        % than the dimensionality of the array).
    end
    properties ( Access = private )
        % GlobalRegions is a struct with 2 elements - "start" and "end", each of
        % which is lpndims-by-numregions, each column represents the limits
        % of a given region in global address space
        GlobalRegions

        % This is an array of local part offsets, lpndims-by-numRegions,
        % representing the starting point in the local part of the current
        % region.
        LocalPartOffsets
    end

    methods ( Static )
        function obj = buildDescriptor( dOrCoD )
            if isa( dOrCoD, 'distributed' )
                obj = spmd_feval_fcn( @distributedutil.CodistributedDescriptor.buildDescriptor, ...
                                      { dOrCoD } );
                obj = obj{1};
            elseif isa( dOrCoD, 'codistributed' )
                obj = iBuildDescriptorFromCod( dOrCoD );
            else
                error( 'distcomp:CodistributedDescriptor:InvalidClass', ...
                       'Cannot build a CodistributedDescriptor for objects of class: %s', ...
                       class( dOrCoD ) );
            end
        end
    end

    methods ( Access = private )
        function obj = CodistributedDescriptor( numReg, arrayNDims, labForRegion, globalStarts, ...
                                                globalEnds, lpOffsets )
            % Check consistency of all arguments:
            obj.ArrayNDims = arrayNDims;
            obj.LPNDims = size( lpOffsets, 1 );
            if isequal( size( labForRegion ), [numReg, 1] ) && ...
                    isequal( size( globalStarts ), [obj.LPNDims, numReg] ) && ...
                    isequal( size( globalEnds ), [obj.LPNDims, numReg] ) && ...
                    isequal( size( lpOffsets ), [obj.LPNDims, numReg] ) && ...
                    obj.ArrayNDims <= obj.LPNDims
                % Ok
            else
                error( 'distcomp:CodistributedDescriptor:InvalidSizes', ...
                       ['Invalid combination of sizes of arguments ', ...
                        ' to CodistributedDescriptor constructor'] );
            end
            obj.NumRegions       = numReg;
            obj.LabOwningRegion  = labForRegion;
            obj.GlobalRegions    = struct( 'start', globalStarts, 'end', globalEnds );
            obj.LocalPartOffsets = lpOffsets;
        end
    end

    methods ( Access = public )
        function [csLims, lpLims, labs] = mapGlobalRegion( obj, globalSelectionStruct )
        % General mapping function; inputs:
        % 1. The CodistributedDescriptor object
        % 2. A region structure of the right array dimensionality selecting a sub-region
        % of the global address space.
        % Outputs:
        % 1. The (client-side) global-index limits for each region, as a region structure
        % 2. The (remote, on the appropriate lab) local-part limits for each region as a structure
        % 3. The lab on which that region lives
        % Each output argument is trimmed so that only regions which select some
        % elements are returned. The outputs are also trimmed so that they
        % are in the dimensionality of the global array. 
            
            if isfield( globalSelectionStruct, 'start' ) &&  ...
                    isfield( globalSelectionStruct, 'end' ) && ...
                    isequal( size( globalSelectionStruct.start ), [obj.ArrayNDims, 1] ) && ...
                    isequal( size( globalSelectionStruct.end ), [obj.ArrayNDims, 1] )
                % Ok
            else
                error( 'distcomp:distributedutil:CodistributedDescriptor:BadStartPoint', ...
                       'The size of the starting point or number of elements was invalid' );
            end
            
            if obj.ArrayNDims ~= obj.LPNDims
                % Temporarily expand the global selection into LP Ndims.
                globalSelectionStruct.start = [ globalSelectionStruct.start; ...
                                    ones( obj.LPNDims - obj.ArrayNDims, 1 ) ];
                globalSelectionStruct.end = [ globalSelectionStruct.end; ...
                                    ones( obj.LPNDims - obj.ArrayNDims, 1 ) ];
            end

            labs = obj.LabOwningRegion;

            % Replicate globalSelectionStruct to have NumRegions columns to match size of
            % GlobalRegions.(start|end)
            globalStartsRep = repmat( globalSelectionStruct.start, [1, obj.NumRegions] );
            globalEndsRep   = repmat( globalSelectionStruct.end, [1, obj.NumRegions] );

            % Build the starting and ending points. Considering a single dimension, for
            % each region, the start point in global address space of the
            % intersection (of that region and the selection region) is
            % simply the larger of the two.
            csLims.start = max( obj.GlobalRegions.start, globalStartsRep );
            csLims.end   = min( obj.GlobalRegions.end, globalEndsRep );

            % We need to find the limits into the local part. In each dimension, we need
            % the difference between the start of the region, and the start
            % of what we've selected. We must then add to that the local
            % part offset for this region.
            startingPointsInLPIgnoringOffset = 1 + csLims.start - obj.GlobalRegions.start;
            startingPointsInLP = startingPointsInLPIgnoringOffset + obj.LocalPartOffsets;
            
            sizeLess1 = csLims.end - csLims.start;
            endingPointsInLP = startingPointsInLP + sizeLess1;
            lpLims = struct( 'start', startingPointsInLP, ...
                             'end', endingPointsInLP );

            % Calculate "got flag" from lpLims by selecting those columns whose elements
            % are all >= 0.
            gotFlag = all( sizeLess1 >= 0, 1 );

            % Trim regions by gotFlag and ArrayNDims. This requires that indexing the LP
            % by this number of dimensions will give correct results for any
            % regions which actually select some elements.
            csLims.start = csLims.start( 1:obj.ArrayNDims, gotFlag );
            csLims.end   = csLims.end( 1:obj.ArrayNDims, gotFlag );
            lpLims.start = lpLims.start( 1:obj.ArrayNDims, gotFlag );
            lpLims.end   = lpLims.end( 1:obj.ArrayNDims, gotFlag );
            labs         = labs( gotFlag );
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = iBuildDescriptorFromCod( coD )
% Prototype codistributed method
    codist = getCodistributor( coD );
    fullSizeColumn = size( coD ).';
    switch class( codist )
      case 'codistributor1d'
        obj = i1DDescriptor( fullSizeColumn, codist );
      case 'codistributor2dbc'
        obj = i2DbcDescriptor( fullSizeColumn, codist, coD );
      otherwise
        error( 'distributedutil:CodistributedDescriptor:InvalidDistributionScheme', ...
               'Cannot build a CodistributedDescriptor for distribution scheme: %s', ...
               class( codist ) );
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Build a CodistributedDescriptor from a 1-d distribution scheme. 1 region
% per lab.
function obj = i1DDescriptor( fullSizeColumn, codist )
    distDim        = codist.Dimension;
    distPar        = codist.Partition;
    numRegions     = numlabs;
    labForRegion   = (1:numlabs).';

    % The array NDims is simply the length of the fullSizeColumn
    ndimsArray       = length( fullSizeColumn );

    % The local part has at least 2 dimensions, and has at least as many as
    % distDim. We deal in this number of dimensions henceforth.
    ndimsLP          = max( [2, ndimsArray, distDim] );
    fullSizeInLPDims = [ fullSizeColumn; ones( ndimsLP - ndimsArray, 1 ) ];
    
    
    % Calculate global regions: all labs have all data, except in distDim
    globalStarts   = ones( ndimsLP, numRegions );
    globalEnds     = repmat( fullSizeInLPDims, [1, numRegions] );
    endsInDistDim   = cumsum( distPar );
    startsInDistDim = 1 + (endsInDistDim - distPar);
    globalStarts( distDim, : ) = startsInDistDim;
    globalEnds( distDim, : ) = endsInDistDim;
    
    % Offsets into the local part are all zero - each region is a whole local part.
    lpOffsets = zeros( ndimsLP, numRegions );

    obj = distributedutil.CodistributedDescriptor( numRegions, ndimsArray, labForRegion, ...
                                                   globalStarts, globalEnds, lpOffsets );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = i2DbcDescriptor( fullSizeColumn, codist, tmpCod )
% Extract properties from the codistributor:
blkSize    = codist.BlockSize;

% Calculate how many rows and columns of individual blocks there are so that
% we can pre-allocate the various things. We might be slightly out.
blocksRC   = ceil( fullSizeColumn.' / blkSize );
blocksRC( blocksRC == 0 ) = 1;

% This might be incorrect - it may turn out to be too small.
numRegions   = prod( blocksRC );

% Dimensionality of both array and LP always 2 in this case
ndimsArray   = 2;
ndimsLP      = ndimsArray;

labForRegion = zeros( numRegions, 1 );
lpOffsets    = zeros( ndimsLP, numRegions );
globalStarts = zeros( ndimsLP, numRegions );
globalEnds   = zeros( ndimsLP, numRegions );

% We don't know a-priori how many blocks are on each lab, so increment a
% counter after each region.
region       = 1;

for lab = 1:numlabs
    % TODO: use hGlobalIndicesImpl once refactored
    [rowStart, rowEnd] = globalIndices( tmpCod, 1, lab );
    [colStart, colEnd] = globalIndices( tmpCod, 2, lab );
    % Create nr-by-nc matrices of all the possible values of colStart and
    % rowStart, and also calculate the block sizes.
    nr = length(rowStart);
    nc = length(colStart);
    numColsInBlock = repmat(colEnd(:)' - colStart(:)' + 1, nr, 1);
    numRowsInBlock = repmat(rowEnd(:) - rowStart(:) + 1, 1, nc);

    for lpRow = 1:nr
        for lpCol = 1:nc
            globalStarts( 1, region ) = rowStart( lpRow );
            globalEnds( 1, region ) = rowStart( lpRow ) + numRowsInBlock( lpRow ) - 1;
            globalStarts( 2, region ) = colStart( lpCol );
            globalEnds( 2, region ) = colStart( lpCol ) + numColsInBlock( lpCol ) - 1;
            lpOffsets( 1, region ) = blkSize * (lpRow - 1);
            lpOffsets( 2, region ) = blkSize * (lpCol - 1);
            labForRegion( region, 1 ) = lab; % Keep this the right shape even if we grow.
            region = region + 1;
        end
    end
end
% Update numRegions now that we have the final count.
numRegions = region - 1;

obj = distributedutil.CodistributedDescriptor( numRegions, ndimsArray, labForRegion, ...
                                               globalStarts, globalEnds, lpOffsets );
end
