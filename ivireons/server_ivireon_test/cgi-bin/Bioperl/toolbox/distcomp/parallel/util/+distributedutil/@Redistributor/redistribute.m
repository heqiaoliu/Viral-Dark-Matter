function [LP, destCodistr] = redistribute(codistr, LP, destCodistr)
%REDISTRIBUTE Undocumented implementation of redistribute on codistributed arrays.

%   Copyright 2009 The MathWorks, Inc.
%   $Revision: 1.1.6.4 $  $Date: 2009/09/23 13:59:33 $
try
    iVerifyCodistributors(codistr, LP, destCodistr)
catch E
    throwAsCaller(E); % Let errors stack show codistributed.redistribute.
end

% Ensure that we have a fully specified codistributor for the destination.
destCodistr = destCodistr.hGetCompleteForSize(codistr.Cached.GlobalSize);
if isequal(codistr, destCodistr)
    return;
end

% Handle the special cases where we can write simple and effective code before
% calling the generalized tensor product redistribution function.
if distributedutil.Redistributor.pIs1DOnOneLab(codistr) ...
    % The entire input array is on one lab, and all the other labs have an empty
    % local part.  The resulting output array may or may not be on a single lab.
    srcLab = find(codistr.Partition ~= 0);
    [LP, destCodistr] = destCodistr.hBuildFromReplicatedImpl(srcLab, LP); %#ok<FNDSB> 
elseif distributedutil.Redistributor.pIs1DOnOneLab(destCodistr)
    % The output array will all be on one lab.
    % Gather the array to the lab where the data will live, and allocate an empty
    % array of the appropriate size on the other labs.
    destLab = find(destCodistr.Partition ~= 0);
    templ = distributedutil.Allocator.extractTemplate(LP);
    LP = codistr.hGatherImpl(LP, destLab);
    if labindex ~= destLab
        LP = distributedutil.Allocator.create(destCodistr.hLocalSize(), templ);
    end
else
    % At this point, we know that if either codistr or destCodistr is 1D, then its
    % Dimension is < ndims.  This means we've reduced the number of dimensions
    % involved in any redistribution between 1D and 2DBC to only involve dimensions
    % 1 and 2.
    BLP = distributedutil.Allocator.create(destCodistr.hLocalSize(), LP);
    BLP = distributedutil.Redistributor.redistributeInto(codistr, LP, ...
                                                      destCodistr, BLP);
    LP = BLP;
end
end % End of redistribute.

function iVerifyCodistributors(codistr, LP, destCodistr)
% Try to do as much up-front verification as we can.  Since the error checking
% is very specific to the distribution schemes in question, we may not be able
% to capture them all.
 
isTP = @(x) isa(x, 'TensorProductCodistributor');
if ~(isTP(codistr) && isTP(destCodistr) )
    error('distcomp:Redistributor:redistribute:UnsupportedCodistributor', ...
          'Redistribution between %s and %s is not supported.', ...
          class(codistr), class(destCodistr));
end

if isa(destCodistr, 'codistributor2dbc') && length(codistr.Cached.GlobalSize) > 2 
    error('distcomp:Redistributor:redistribute:NDwith2DBC', ...
          ['Cannot redistribute ND arrays to use the 2D block-cyclic '...
           'codistributor.']);
end

if issparse(LP) 
    destCodistr.hVerifySupportsSparse();
end

if ~isempty(destCodistr.Cached.GlobalSize) ...
        && ~isequal(destCodistr.Cached.GlobalSize, codistr.Cached.GlobalSize)
    error('distcomp:Redistributor:redistribute:InvalidTargetSize', ...
          ['Target codistributor does not match the size of the array to ' ...
           'redistribute.  The array is of size [%s], whereas the target ' ...
           'codistributor is expecting the array to be of size [%s].'], ...
          num2str(codistr.Cached.GlobalSize), num2str(destCodistr.Cached.GlobalSize));
end
end % End of iVerifyCodistributors.

