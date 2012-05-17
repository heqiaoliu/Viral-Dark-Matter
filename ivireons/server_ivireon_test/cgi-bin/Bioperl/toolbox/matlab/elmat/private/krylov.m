function B = krylov(A, x, j, classname)
%KRYLOV Krylov matrix.
%   GALLERY('KRYLOV',A,X,J) is the Krylov matrix
%   [X, A*X, A^2*X, ..., A^(J-1)*X], where A is an N-by-N matrix and
%   X is an N-vector. The defaults are X = ONES(N,1), and J = N.
%
%   GALLERY('KRYLOV',N) is the same as GALLERY('KRYLOV',RANDN(N)).

%   Reference:
%   G. H. Golub and C. F. Van Loan, Matrix Computations, third edition,
%   Johns Hopkins University Press, Baltimore, Maryland, 1996, Sec. 7.4.5.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.11.4.1 $  $Date: 2005/11/18 14:15:07 $

n = length(A);

if n == 1   % Handle special case A = scalar.
   n = A;
   A = cast(randn(n),classname);
end

if isempty(j), j = n; end
if isempty(x), x = ones(n,1,classname); end

B = ones(n,j,classname);
B(:,1) = x(:);
for i=2:j
    B(:,i) = A*B(:,i-1);
end
