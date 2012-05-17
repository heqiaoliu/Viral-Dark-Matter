%EIG    Eigenvalues and eigenvectors.
%   E = EIG(X) is a vector containing the eigenvalues of a square 
%   matrix X.
%
%   [V,D] = EIG(X) produces a diagonal matrix D of eigenvalues and a
%   full matrix V whose columns are the corresponding eigenvectors so
%   that X*V = V*D.
%
%   [V,D] = EIG(X,'nobalance') performs the computation with balancing
%   disabled, which sometimes gives more accurate results for certain
%   problems with unusual scaling. If X is symmetric, EIG(X,'nobalance')
%   is ignored since X is already balanced.
%
%   E = EIG(A,B) is a vector containing the generalized eigenvalues
%   of square matrices A and B.
%
%   [V,D] = EIG(A,B) produces a diagonal matrix D of generalized
%   eigenvalues and a full matrix V whose columns are the
%   corresponding eigenvectors so that A*V = B*V*D.
%
%   EIG(A,B,'chol') is the same as EIG(A,B) for symmetric A and symmetric
%   positive definite B.  It computes the generalized eigenvalues of A and B
%   using the Cholesky factorization of B.
%   EIG(A,B,'qz') ignores the symmetry of A and B and uses the QZ algorithm.
%   In general, the two algorithms return the same result, however using the
%   QZ algorithm may be more stable for certain problems.
%   The flag is ignored when A and B are not symmetric.
%
%   See also CONDEIG, EIGS, ORDEIG.

%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 5.13.4.6 $  $Date: 2005/06/21 19:35:51 $
%   Built-in function.

