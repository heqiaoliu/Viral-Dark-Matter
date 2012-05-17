function hVerifySupportsSparse(codistr)
% Throw an error if the codistributor is not suitable for sparse codistributed
% arrays.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.2 $  $Date: 2010/04/21 21:14:39 $   

numDims = length(codistr.Cached.GlobalSize);
if numDims > 2
    ex = MException('distcomp:codistributor1d:SparseSupport:NDNotSupported', ...
                    'N-D sparse is not supported.');
    throwAsCaller(ex);
end

if codistr.Dimension > 2
    ex = MException('distcomp:codistributor1d:SparseSupport:TooHighDistributionDim', ... 
                    ['Sparse arrays cannot be distributed along dimension %d ' ...
                     'with the codistributor1d codistributor.  ' ...
                     'Only dimensions 1 or 2 are valid distribution dimensions for '...
                     'sparse arrays.'], ...
                    codistr.Dimension);
    throwAsCaller(ex);
end

end % End of hVerifySupportsSparse.
         
    
