function A = mldivide(A, B)
%\ Backslash or left matrix divide for codistributed arrays
%   X = A \ B is the matrix division of A into B, where either A or B or both are
%   codistributed.  This is roughly the same as INV(A)*B, except it is computed in a 
%   different way.  If A is an N-by-N matrix and B is a column vector with N
%   components, or a matrix with several such columns, then X = A\B is the 
%   solution to the equation A*X = B.  A\EYE(SIZE(A)) produces the inverse of A.
%   
%   If A is an M-by-N matrix with M < or > N and B is a column vector with M
%   components, or a matrix with several such columns, then X=A\B is the solution
%   in the least squares sense to the under- or over-determined system of 
%   equations A*X = B.  A\EYE(SIZE(A)) produces a generalized inverse of A.
%   
%   X = MLDIVIDE(A,B) is called for the syntax A\B when A or B is an object.
%   
%   Example:
%   spmd
%       N = 1000;
%       A = codistributed.rand(N);
%       B = codistributed.rand(N,1);
%       X = A \ B
%       norm(B-A*X, 1)
%   end
%   
%   See also MLDIVIDE, CODISTRIBUTED, CODISTRIBUTED/RAND.


%   Copyright 2006-2010 The MathWorks, Inc.
%   $Revision: 1.1.6.9 $  $Date: 2010/05/10 17:08:30 $

if isscalar(A)
   A = codistributed.pElementwiseBinaryOp(@ldivide, A, B); %#ok<DCUNK>
   return;
end

if iIsUnsupported(A) || iIsUnsupported(B)  
    error('distcomp:codistributed:mldivide:notSupported', ...
          ['MLDIVIDE is only supported for codistributed full ', ...
          'floating point arrays (single or double).']);
end

if isa(A, 'codistributed')
    if issparse(A) || issparse(B)
        error('distcomp:codistributed:mldivide:sparseInput',...
              'Sparse input arguments are not yet supported.');
    end
    if size(A, 1) == size(A, 2) % square
        % Check whether A is triangular and use the most efficient solver
        lDivide = 'Left';
        aDist = getCodistributor(A);
        matrixType = aDist.hIsTriangularImpl(getLocalPart(A));
        if strcmp(matrixType, 'NotTriangular')
            [A, rCond] = scalaLUsolve(A, B);
        elseif any(strncmpi(matrixType, {'LowerTriangular', 'UpperTriangular'}, 1))
            [A, rCond] = scalaTrisolve(A, B, lDivide, matrixType);
        else  % Diagonal or zero
            [A, rCond] = scalaTrisolve(A, B, lDivide,...
                'LowerTriangular');
        end
        if isnan(rCond) || ( rCond < eps(class(rCond)) )
            warning('distcomp:codistributed:mldivide:nearlySingularMatrix',...
                  ['Matrix is close to singular or badly scaled.\n'...
                  'Results may be inaccurate.']);
        end
    else  % not square
        A = scalaQRsolve(A, B);
    end
else
    bDist = getCodistributor(B);
    if ~( isa(bDist, 'codistributor1d') && (bDist.Dimension == 2) ) 
        B = redistribute(B, codistributor('1d', 2, ...
                            codistributor1d.defaultPartition(size(B, 2))));
        bDist = getCodistributor(B);
    end
    % Since A is not codistributed and B is distributed by columns, the 
    % labs all have different linear systems to solve.  A new codistributor
    % will be needed if A is not square.  In any case, the results of the
    % mldivide operation will have the same column distribution as B, and 
    % the number of rows will be the number of columns in the input A
    aDist = codistributor('1d', 2, bDist.Partition, [size(A, 2) size(B, 2)]);
    A = codistributed.pDoBuildFromLocalPart(A\getLocalPart(B), aDist); %#ok<DCUNK>
end
end

%------------------------------------
function tf = iIsFloatArray(obj)
    if iscodistributed(obj)
        tf = isaUnderlying(obj, 'float');
    else
        tf = isa(obj, 'float');
    end
end 

%------------------------------------
function tf = iIsUnsupported(D)
    tf = ~iIsFloatArray(D) || ndims(D) > 2;
end
