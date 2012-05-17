function T = toeppd(n, m, w, theta, classname)
%TOEPPD Symmetric positive definite Toeplitz matrix.
%   GALLERY('TOEPPD',N,M,W,THETA) is an N-by-N symmetric positive
%   semi-definite (SPD) Toeplitz matrix. It is composed of the sum of
%   M rank 2 (or, for certain THETA rank 1) SPD Toeplitz matrices.
%   Specifically,
%      T = W(1)*T(THETA(1)) + ... + W(M)*T(THETA(M)),
%   where T(THETA(k)) has (i,j) element COS(2*PI*THETA(k)*(i-j)).
%
%   Defaults: M = N, W = RAND(M,1), THETA = RAND(M,1).

%   Reference:
%   G. Cybenko and C. F. Van Loan, Computing the minimum eigenvalue of
%   a symmetric positive definite Toeplitz matrix, SIAM J. Sci. Stat.
%   Comput., 7 (1986), pp. 123-131.
%
%   Copyright 1984-2005 The MathWorks, Inc.
%   $Revision: 1.10.4.2 $  $Date: 2005/11/18 14:15:33 $

if isempty(m), m = n; end
if isempty(w), w = rand(m,1); end
if isempty(theta), theta = rand(m,1); end

if length(w) ~= m || length(theta) ~= m
   error('MATLAB:toeppd:InvalidLengthWAndTheta',...
         'Arguments W and THETA must be vectors of length M.')
end

T = zeros(n,classname);
e = cast(1:n,classname);
E = e(ones(n,1),:);
E = 2*pi*(E' - E);

for i=1:m
    T = T + w(i) * cos( theta(i)*E );
end
