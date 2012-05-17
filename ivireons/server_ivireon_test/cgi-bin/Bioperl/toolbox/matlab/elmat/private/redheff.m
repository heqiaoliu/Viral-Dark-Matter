function A = redheff(n,classname)
%REDHEFF Redheffer matrix.
%   A = GALLERY('REDHEFF',N) is an N-by-N matrix of 0s and 1s
%   defined by
%      A(i,j) = 1, if j = 1 or if i divides j,
%             = 0 otherwise.
%
%   Properties:
%   A has N-FLOOR(LOG2(N))-1 eigenvalues equal to 1,
%   a real eigenvalue (the spectral radius) approximately SQRT(N),
%   a negative eigenvalue approximately -SQRT(N),
%   and the remaining eigenvalues are provably "small".
%
%   The Riemann hypothesis is true if and only if
%   DET(A) = O( N^(1/2+epsilon) ) for every epsilon > 0.
%
%   Note:
%   Barrett and Jarvis [1] conjecture that "the small eigenvalues
%   all lie inside the unit circle ABS(Z) = 1". A proof of this
%   conjecture, together with a proof that some eigenvalue tends to
%   zero as N tends to infinity, would yield a new proof of the
%   prime number theorem.
%
%   See also GALLERY('RIEMANN',N).

%   Reference:
%   [1] W. W. Barrett and T. J. Jarvis, Spectral Properties of a
%       Matrix of Redheffer, Linear Algebra and Appl.,
%       162 (1992), pp. 673-683.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.11.4.3 $  $Date: 2005/11/18 14:15:29 $

i = (1:n)'; i = cast( i(:,ones(1,n)), classname );
A = cast(~rem(i',i),classname);
A(:,1) = ones(n,1,classname);
