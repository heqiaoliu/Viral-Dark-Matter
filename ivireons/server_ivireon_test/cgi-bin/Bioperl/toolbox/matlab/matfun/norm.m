%NORM   Matrix or vector norm.
%
%   For matrices...
%     NORM(X) is the 2-norm of X.
%     NORM(X,2) is the same as NORM(X).
%     NORM(X,1) is the 1-norm of X.
%     NORM(X,inf) is the infinity norm of X.
%     NORM(X,'fro') is the Frobenius norm of X.
%     NORM(X,P) is available for matrix X only if P is 1, 2, inf or 'fro'.
%
%   For vectors...
%     NORM(V,P) = sum(abs(V).^P)^(1/P).
%     NORM(V) = norm(V,2).
%     NORM(V,inf) = max(abs(V)).
%     NORM(V,-inf) = min(abs(V)).
%
%   See also COND, RCOND, CONDEST, NORMEST, HYPOT.

%   Copyright 1984-2009 The MathWorks, Inc.
%   $Revision: 5.13.4.6 $  $Date: 2009/06/16 04:18:46 $
%   Built-in function.

