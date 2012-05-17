%DORMQR  Apply Householder vectors obtained from DGEQRF.
%   Mex-file interface to LAPACK.
%   [HR,tau] = dgeqrf(A)
%   Y = dormqr(side,trans,HR,tau,X)
%   side,trans =
%       'L','N': Y = Q*X
%       'L','T': Y = Q'*X
%       'R','N': Y = X*Q
%       'R','T': Y = X*Q'

%   Copyright 2006-2007 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $  $Date: 2007/11/09 20:01:18 $
