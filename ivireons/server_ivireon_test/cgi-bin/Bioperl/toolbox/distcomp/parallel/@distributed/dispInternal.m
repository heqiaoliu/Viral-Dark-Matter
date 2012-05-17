function dh = dispInternal( obj, className, objName )
;%#ok undocumented

% Return a distributedutil.DisplayHelper object

% Copyright 2008-2009 The MathWorks, Inc.
% $Revision: 1.1.6.5 $   $Date: 2009/07/18 15:51:39 $

% Deal with closed pool / invalid object up front, with early return.
if ~obj.isValid()
    
    if ~obj.isResourceSetOpen()
        % The pool that this referred to has been closed
        msg = ' (the matlabpool in use has been closed)';
    else
        % No clear reason - could have been load/save
        msg = '';
    end
    
    dh = distributedutil.DisplayHelperInvalid( objName, className, msg );
    return
end

if numel( obj ) == 0
    % Send the gathered empty data through to the helper so that it has the
    % correct underlying class (i.e. int8/single/whatever)
    if issparse( obj )
        dh = distributedutil.DisplayHelperSparse( objName, className, gather( obj ), nnz( obj ) );
    else
        dh = distributedutil.DisplayHelperDense( objName, className, gather( obj ), size( obj ) );
    end
else
    N = 1000;
    dh = iBuildDisplayHelper( obj, className, objName, N );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function dh = iBuildDisplayHelper( x, className, name, N )

% One day, we'll use isnumeric here.
if iIsNumericIsh( x )
    dh = iFirstNNumericDisplayHelper( x, className, name, N );
else
    dh = distributedutil.DisplayHelperOther( name, className, ...
                                             classUnderlying( x ), size( x ) );
end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function tf = iIsNumericIsh( x )
numericIshClasses = { 'double', 'single', ...
                    'int8', 'uint8', 'int16', 'uint16', 'int32', 'uint32', ...
                    'int64', 'uint64', ...
                    'logical' };
tf = ismember( classUnderlying( x ), numericIshClasses );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% For a numeric style distributed array, display the first N entries.
function dh = iFirstNNumericDisplayHelper( x, className, name, N )

if issparse( x )
    totalEls = nnz( x );
    if totalEls > N
        maybeTruncatedValue = iSparseNTruncate( x, N );
    else
        maybeTruncatedValue = gather( x );
    end
    dh = distributedutil.DisplayHelperSparse( name, className, ...
                                              maybeTruncatedValue, totalEls );
else
    totalEls = numel( x ); 
    if totalEls > N
        maybeTruncatedValue = iDenseNTruncate( x, N );
    else
        maybeTruncatedValue = gather( x );
    end
    % Using the 4-arg ctor since we always truncate from 1:N in each dim
    dh = distributedutil.DisplayHelperDense( name, className, maybeTruncatedValue, ...
                                             size( x ) );
end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% display the first N entries of a sparse distributed
function truncated = iSparseNTruncate( x, N )
% Sparse truncation - simply pick the first N elements
truncated = spmd_feval_fcn( @iSparseNTruncateI, {x, N} );
truncated = truncated.Value;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Run in parallel on a sparse codistributed - pick the first N using "find 'first'",
% let's hope that's a good choice for codistributed.
function truncated = iSparseNTruncateI( x, N )

% Find the linear indices of the first N
linInd = gather( find( x, N, 'first' ) );

% Gather to lab 1 that portion of x
tmp = gather( x( linInd ), 1 ); 

% Collectively call "size"
[m, n] = size( x );
if labindex == 1
    % Construct "to_disp" only on lab 1, that's all the AutoTransfer needs
    truncated = spalloc( m, n, N );
    truncated( linInd ) = tmp;
else
    truncated = [];
end

% truncated has the correct value only on lab 1
truncated = distributedutil.AutoTransfer( truncated, 1 );
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% iChooseArgsForPages - build up subsargs to subsref an array, and a
% trunc_message for the case where we're selecting whole pages
function range = iChooseRangeForPages( fullSz, szProd, N )

% cutoverDim is the first dimension which overflows N, we wont take all of
% that dimension back to the client for display.
cutoverDim = find( szProd > N, 1, 'first' );

% Pick how many elements in the cutoverDim to bring back. Note that by
% calling ceil, we might bring back at most 2*N elements.
numInCutoverDim = ceil( N / szProd(cutoverDim-1) );

% Build range to subselect x
range.start                 = ones( length( fullSz ), 1 );
range.end                   = ones( length( fullSz ), 1 );
range.end( 1:cutoverDim-1 ) = fullSz( 1:cutoverDim - 1 );
range.end( cutoverDim )     = numInCutoverDim;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function range = iChooseRangeTruncatingFirstPage( sz, fullSz, N )
% We can display only part of the first page, pre-allocate the subsargs with
% ones.

% Use a heuristic method to truncate. My heuristic is: do not truncate any
% dimension smaller than TRUNCATE_THRESH; if truncating both
% dimensions, attempt to keep the aspect ratio approximately correct.
TRUNCATE_THRESH = min( 20, ceil( sqrt( N ) ) );

range.start      = ones( length( fullSz ), 1 );
range.end        = ones( length( fullSz ), 1 );
range.end( 1:2 ) = sz( 1:2 );
% NB - in higher dimensions, default range of [1 1] is Ok.

firstTwoSizeElements = sz(1:2);

canTruncate = firstTwoSizeElements > TRUNCATE_THRESH;

if all( canTruncate )
    aspectRatio      = firstTwoSizeElements(1) / firstTwoSizeElements(2);
    newRows          = ceil( sqrt( N * aspectRatio ) );
    newCols          = ceil( sqrt( N / aspectRatio ) );
    % Truncate in both dimensions
    range.end( 1:2 ) = [newRows, newCols];
elseif any( canTruncate )
    % Truncate in one dimension
    truncated                = canTruncate;
    truncatedTo              = firstTwoSizeElements;
    truncatedTo( truncated ) = ceil( N / firstTwoSizeElements( ~truncated ) );
    range.end( truncated )   = truncatedTo( truncated );
end    

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Dense truncation. If we can display whole "pages", do as many of those as
% we can in as many dimensions as possible. Otherwise, truncate one page and
% show that. When truncating a page, do it in the larger dimension.
function truncated = iDenseNTruncate( x, N )

sz         = size( x );
szprod     = cumprod( sz );

if szprod( 2 ) <= N
    % The first page is smaller than N, so pick some pages
    rangeStruct = iChooseRangeForPages( sz, szprod, N );
else
    % The first page is too big, truncate that page, and pick only 1 in all
    % subsequent dimensions
    rangeStruct = iChooseRangeTruncatingFirstPage( sz, szprod, N );
end

truncated = transferPortion( x, rangeStruct );
end
