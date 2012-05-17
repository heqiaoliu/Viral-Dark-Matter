%DGEQRF  First step of QR factorization
%   Mex-file interface to LAPACK.
%   [HR,tau] = dgeqrf(A)
%   R = triu(HR) is the R of the QR factorization.
%   Columns of tril(HR,-1), together with tau, define Householder
%   transformations, H_k = I - tau(k)*v_k*v_k' where
%   v_k = [zeros(k-1,1); 1; H(k+1:m,k)]
%
%   See also DORMQR.

%   Copyright 2006 The MathWorks, Inc.
%   $Revision: 1.1.8.1 $  $Date: 2006/06/11 17:09:30 $
