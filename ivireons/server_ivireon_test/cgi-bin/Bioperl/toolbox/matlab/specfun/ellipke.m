function [k,e] = ellipke(m,tol)
%ELLIPKE Complete elliptic integral.
%   [K,E] = ELLIPKE(M) returns the value of the complete elliptic
%   integrals of the first and second kinds, evaluated for each
%   element of M.  As currently implemented, M is limited to 0 <= M <= 1.
%   
%   [K,E] = ELLIPKE(M,TOL) computes the complete elliptic integrals to
%   the accuracy TOL instead of the default TOL = EPS(CLASS(M)).
%
%   Some definitions of the complete elliptic integrals use the modulus
%   k instead of the parameter M.  They are related by M = k^2.
%
%   Class support for input M:
%      float: double, single
%
%   See also ELLIPJ.

%   Modified to include the second kind by Bjorn Bonnevier
%   from the Alfven Laboratory, KTH, Stockholm, Sweden
%   Copyright 1984-2007 The MathWorks, Inc. 
%   $Revision: 5.18.4.5 $  $Date: 2007/05/23 18:55:00 $

%   ELLIPKE uses the method of the arithmetic-geometric mean
%   described in [1].

%   References:
%   [1] M. Abramowitz and I.A. Stegun, "Handbook of Mathematical
%       Functions" Dover Publications", 1965, 17.6.

if nargin<1
  error('MATLAB:ellipke:NotEnoughInputs','Not enough input arguments.'); 
end

classin = superiorfloat(m);

if nargin<2, tol = eps(classin); end
if ~isreal(m),
    error('MATLAB:ellipke:ComplexInputs', 'Input arguments must be real.')
end
if isempty(m), k = zeros(size(m),classin); e = k; return, end
if any(m(:) < 0) || any(m(:) > 1), 
  error('MATLAB:ellipke:MOutOfRange', 'M must be in the range 0 <= M <= 1.');
end

a0 = 1;
b0 = sqrt(1-m);
s0 = m;
i1 = 0; mm = 1;
while mm > tol
    a1 = (a0+b0)/2;
    b1 = sqrt(a0.*b0);
    c1 = (a0-b0)/2;
    i1 = i1 + 1;
    w1 = 2^i1*c1.^2;
    mm = max(w1(:));
    s0 = s0 + w1;
    a0 = a1;
    b0 = b1;
end
k = pi./(2*a1);
e = k.*(1-s0/2);
im = find(m ==1);
if ~isempty(im)
    e(im) = ones(length(im),1);
    k(im) = inf;
end

