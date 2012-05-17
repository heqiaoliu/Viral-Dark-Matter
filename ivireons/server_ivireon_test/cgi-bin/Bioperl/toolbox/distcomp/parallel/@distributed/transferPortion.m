function x = transferPortion( obj, rangeStruct, value )
%transferPortion - attempt to transfer an array portion efficiently

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.2 $   $Date: 2009/04/15 23:01:33 $

% Check the range against the size of the distributed object itself.
if isfield( rangeStruct, 'start' ) && isfield( rangeStruct, 'end' ) && ...
        all( rangeStruct.start(:) > 0 ) && ...
        all( rangeStruct.end <= size( obj ).' ) && ...
        length( rangeStruct.start ) == ndims( obj ) && ...
        isequal( size( rangeStruct.start ), size( rangeStruct.end ) )
    % ok
else
    error( 'distcomp:distributed:BadRangeForTransferPortion', ...
           'An invalid range was specified for transferPortion' );
end

% Compute the size of data corresponding to the range. 
szColumnFromRange = 1 + rangeStruct.end - rangeStruct.start;
szColumnFromRange( szColumnFromRange < 0 ) = 0;
% Remove trailing ones
szColumnFromRange = distributedutil.Sizes.removeTrailingOnes( szColumnFromRange );

if nargin == 2 % No value - retrieval
    x = iCreateLocalDataForRetrieval( obj, szColumnFromRange );
    doRetrieveData = true;
    if isempty( x )
        % No data to retrieve - leave now to save a remote call.
        return;
    end
else           % Assignment
    iArgChecksForAssignment( szColumnFromRange, value );
    doRetrieveData = false;
end

% Call into SPMD to get the cell array of values, and the descriptor
[xferInfo, xferComposite] = spmd_feval_fcn( @iBuildTransferComposite, {obj, rangeStruct, doRetrieveData} );
xferInfo = xferInfo.Value;
[~, csLimsIntoX, labs] = deal( xferInfo{:} );

% Loop over labs, and either retrieve stuff via xferInfo, or plug stuff from
% value into there.
for lab = 1:max( labs )
    % Only retrieve the value from the lab if we must
    regionsForThisLab = find( labs == lab );
    if ~isempty( regionsForThisLab )
        labValue = xferComposite{lab};
    end
    
    % Loop over this lab's regions
    for region=regionsForThisLab.'
        idxInValueCell = labValue.regionToValueCell( region );
        
        % "csLimsIntoX" are limits into the global array range of "obj" that we need
        % either for filling out a piece of "x" (retrieval); or for sending
        % across a piece of "value". In both cases, we need to offset the
        % limits by the start of the range that we're operating on.
        currentStart = 1 + csLimsIntoX.start( :, region ) - rangeStruct.start;
        currentEnd   = 1 + csLimsIntoX.end( :, region )   - rangeStruct.start;

        if doRetrieveData
            dataRetrieved = labValue.values{idxInValueCell};
            thisSubStruct = iSubStructForAssignRange( currentStart, currentEnd );
            % Force in-place optimisation.
            subsasgn( x, thisSubStruct, dataRetrieved );
        else
            labValue.values{idxInValueCell} = iSelectRange( value, currentStart, currentEnd );
        end
    end

    if ~isempty( regionsForThisLab ) && ~doRetrieveData
        % Send the updated value back
        xferComposite{lab} = labValue;
    end
    labValue = [];
end

if ~doRetrieveData
    x = spmd_feval_fcn( @iApplyChanges, {obj, xferComposite} );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function iArgChecksForAssignment( szColumn, value )
% We're doing assignment so check that the span of the range corresponds to
% the size of the value we've been given. Note that "szColumn" has trailing
% ones stripped, so we can compare directly to the size of "value".

if ~all( szColumn == size( value ).' )
    error( 'distcomp:distributed:BadValueForAssignPortion', ...
           'The value specified for assignPortion does not match the specified range' );
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function localData = iCreateLocalDataForRetrieval( obj, szColumn )
% We're doing retrieval, extract the template for construction of x.
tmpl      = distributedutil.Allocator.extractTemplate( obj );
localData = distributedutil.Allocator.create( szColumn.', tmpl );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function obj = iApplyChanges( obj, xferVariant )

lp   = getLocalPart( obj );
dtor = getCodistributor( obj );
for ii=1:length( xferVariant.values )
    thisSubStruct = iSubStructForAssignRange( xferVariant.lpLimsCell{ii}{:} );
    subsasgn( lp, thisSubStruct, xferVariant.values{ii} );
end
% TODO: Could use setLocalPart here.
obj = codistributed.build( lp, dtor, 'noCommunication' );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [xfer, xferComp] = iBuildTransferComposite( obj, range, doRetrieveData )
descriptor = distributedutil.CodistributedDescriptor.buildDescriptor( obj );
[csLimsIntoX, lpLims, labs] = descriptor.mapGlobalRegion( range );
% Work out which regions I own and have values for
nRegions = length( labs );
myEls    = find( labindex == labs );
lp       = getLocalPart( obj );

% Build up the variant which we'll return
xferComp.regionToValueCell = zeros( 1, nRegions );
xferComp.regionToValueCell( myEls ) = 1:length( myEls );
xferComp.lpLimsCell = cell( 1, length( myEls ) );
xferComp.values  = cell( 1, length( myEls ) );
for ii = 1:length( myEls )
    if doRetrieveData
        xferComp.values{ii} = iSelectRange( lp, lpLims.start( :, myEls(ii) ), ...
                                            lpLims.end( :, myEls(ii) ) );
    else
        % We're pushing the data, no need to add the values.
        xferComp.lpLimsCell{ii} = { lpLims.start( :, myEls(ii) ), ...
                            lpLims.end( :, myEls(ii) ) };
    end
end

xfer = distributedutil.AutoTransfer( {descriptor, csLimsIntoX, labs} );
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function x = iSelectRange( data, r_start, r_end )
subsargs = cell( 1, length( r_start ) );
for ii=1:length( r_start )
    subsargs{ii} = r_start( ii ) : r_end( ii );
end
ss = substruct( '()', subsargs );
x = subsref( data, ss );
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function ss = iSubStructForAssignRange( r_start, r_end )
subsargs = cell( 1, length( r_start ) );
for ii=1:length( r_start )
    subsargs{ii} = r_start( ii ) : r_end( ii );
end
ss = substruct( '()', subsargs );
end
