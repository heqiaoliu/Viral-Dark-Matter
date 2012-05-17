function A = lotkin(n,classname)
%LOTKIN Lotkin matrix.
%   A = GALLERY('LOTKIN',N) is the Hilbert matrix with its first row
%   altered to all ones.  A is unsymmetric, ill-conditioned, and has
%   many negative eigenvalues of small magnitude. Its inverse has
%   integer entries and is known explicitly.

%   Reference:
%   M. Lotkin, A set of test matrices, M.T.A.C., 9 (1955), pp. 153-161.
%
%   Nicholas J. Higham
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.10.4.1 $  $Date: 2005/11/18 14:15:12 $

A = hilb(n,classname);
A(1,:) = ones(1,n,classname);
