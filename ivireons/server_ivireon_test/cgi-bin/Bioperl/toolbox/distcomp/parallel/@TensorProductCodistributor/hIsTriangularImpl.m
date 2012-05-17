function matrixType = hIsTriangularImpl(codistr, LP)
%hIsTriangularImpl Implementation for TensorProductCodistributor.

%   Copyright 2009-2010 The MathWorks, Inc.
%   $Revision: 1.1.12.2 $  $Date: 2010/05/10 17:07:02 $

% Check whether a distributed matrix is triangular or not, diagonal, or zero 
% and return a character flag to indicate the outcome

matrixType = 'NotTriangular';  % Default is that matrix is not triangular

nnzU = 0;
nnzL = 0;

if ~isempty( LP )
    gRows = codistr.globalIndices(1, labindex);
    gCols = codistr.globalIndices(2, labindex);

    % Look for 0's off the diagonal
    for j = 1:length(gCols)
        nnzU = nnzU + nnz( LP( gRows < gCols(j), j ) ); % # in upper triangle
        nnzL = nnzL + nnz( LP( gRows > gCols(j), j ) ); % # in lower triangle
    end
end

isLower = gplus(nnzU) == 0;
isUpper = gplus(nnzL) == 0;

if (isLower && isUpper) % diagonal or zero
    if (codistr.hNnzImpl(LP) == 0)  % zero
        matrixType = 'ZeroMatrix';
        return
    else
        matrixType = 'Diagonal';
        return
    end
end

if isLower
    matrixType = 'LowerTriangular';
    return
end

if isUpper
    matrixType = 'UpperTriangular';
    return
end
