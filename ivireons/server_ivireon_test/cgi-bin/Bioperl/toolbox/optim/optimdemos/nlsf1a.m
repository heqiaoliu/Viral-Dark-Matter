function F = nlsf1a(x)
%NLSF1A Nonlinear vector function.
% Documentation example.

%   Copyright 1990-2008 The MathWorks, Inc.
%   $Revision: 1.1.6.3 $  $Date: 2008/02/29 12:47:46 $

%
% Evaluate the vector function
  n = length(x);
  F = zeros(n,1);
  i=2:(n-1);
  F(i)= (3-2*x(i)).*x(i)-x(i-1)-2*x(i+1)+1;
  F(n)= (3-2*x(n)).*x(n)-x(n-1)+1;
  F(1)= (3-2*x(1)).*x(1)-2*x(2)+1;
