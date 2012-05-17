function [a,b] = padecoef(T,n)
%PADECOEF  Pade approximation of time delays.
%
%   [NUM,DEN] = PADECOEF(T,N) returns the Nth-order Pade approximation 
%   of the continuous-time delay exp(-T*s) in transfer function form.
%   The row vectors NUM and DEN contain the polynomial coefficients  
%   in descending powers of s.
%
%   Class support for input T:
%      float: double, single

%   Copyright 1984-2008 The MathWorks, Inc.
%   $Revision: 1.6.4.4 $  $Date: 2008/03/13 17:32:10 $

%  Reference:  Golub and Van Loan, Matrix Computations, 3rd edition,
%              Johns Hopkins University Press, pp. 572-574.

if nargin==1
   n = 1; 
elseif n<0 || T<0
   error('MATLAB:padecoef:NegativeTorN', 'T and N must be nonnegative.')
end
n = round(n);

% The coefficients of the Pade approximation are given by the 
% recursion   h[k+1] = (N-k)/(2*N-k)/(k+1) * h[k],  h[0] = 1
% and 
%     exp(-T*s) == Sum { h[k] (-T*s)^k } / Sum { h[k] (T*s)^k }
%
if T == 0
   a = ones(class(T));
   b = ones(class(T));
else
   a = zeros(1,n+1,class(T));   a(n+1) = 1;
   b = zeros(1,n+1,class(T));   b(n+1) = 1;
   for k = 1:n,
      fact = T*(n-k+1)/(2*n-k+1)/k;
      a(n+1-k) = (-fact) * a(n+2-k);
      b(n+1-k) = fact * b(n+2-k);
   end
   a = a/b(1);
   b = b/b(1);
end
