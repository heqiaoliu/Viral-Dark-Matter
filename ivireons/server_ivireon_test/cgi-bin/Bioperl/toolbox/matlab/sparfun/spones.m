function R = spones(S)
%SPONES Replace nonzero sparse matrix elements with ones.
%   R = SPONES(S) generates a matrix with the same sparsity
%   structure as S, but with ones in the nonzero positions.
%
%   See also SPFUN, SPALLOC, NNZ.

%   Copyright 1984-2010 The MathWorks, Inc. 
%   $Revision: 5.9.4.3 $  $Date: 2010/02/25 08:12:02 $

if ~ismatrix(S)
    error('MATLAB:spones:ndInput','ND-sparse arrays are not supported.');
end
[i,j] = find(S);
[m,n] = size(S);
R = sparse(i,j,1,m,n);
