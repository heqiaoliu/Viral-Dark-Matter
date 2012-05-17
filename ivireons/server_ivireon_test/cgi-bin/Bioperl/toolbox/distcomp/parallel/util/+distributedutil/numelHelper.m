function n = numelHelper( fullSizeVec, varargin )
%numelHelper - common helper for distributed and codistributed numel

% Copyright 2009 The MathWorks, Inc.
% $Revision: 1.1.6.1 $   $Date: 2009/03/25 21:57:10 $

totalNumel = prod( fullSizeVec );
if nargin == 1
    n = totalNumel; 
else
    % Cell-array type indexing, work out how many elements are referenced.
    % Get here when indexing like D{1,3:7,:}
    
    % First of all, use "size" to work out the size in the same dimensionality
    % as requested by varargin. We need to multiply together the trailing
    % elements of fullSizeVec so that it's the same length as varargin:
    requestedDimensionality = length( varargin );
    sizeInRequestedDimensionality = [fullSizeVec(1:requestedDimensionality-1) , ...
                        prod( fullSizeVec( requestedDimensionality:end ) )];
    
    % Calculate the result by multiplying together the number of elements in
    % each dimension. NB that we don't care here whether or not the
    % arguments specified exceed the size of the object.
    result = 1;
    for ii=1:length( varargin )
        arg = varargin{ii};
        
        if ischar( arg ) && strcmp( arg, ':' )
            nthis = sizeInRequestedDimensionality(ii);
        elseif isnumeric( arg ) || islogical( arg ) || ischar( arg )
            % Apparently it is legal to index using other characters too.
            nthis = numel( arg );
        else
            error( 'distcomp:distributed:badIndexType', ...
                   ['A distributed array may not be indexed using an ' ...
                    'object of class: %s'], class( arg ) );
        end
        
        result = result * nthis;
    end
    n = result;
end

end
