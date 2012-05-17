function z = trzero(a,b,c,d,e,tol)
%TRZERO  Computes transmission zeros of MIMO state-space models.
% 
%   Z = TRZERO(A,B,C,D,E,TOL) returns the transmission zeros Z
%   of the state-space model with data (A,B,C,D,E).  TOL is a
%   relative tolerance controlling rank decisions.  Increasing
%   TOL will get rid of zeros near infinity but may incorrectly
%   estimate the relative degree (default = 100*EPS).
%
%   Note: TRZERO does not perform any scaling of (A,B,C,E).
%   
%   LOW-LEVEL UTILITY.

%   Author: P.Gahinet 
%   Copyright 1986-2007 The MathWorks, Inc. 
%   $Revision: 1.1.8.3 $  $Date: 2007/12/14 14:29:27 $
if nargin<6 || isempty(tol) || tol<=0
   tol = 100 * eps;
end

% Exit if NaN's
if any(isnan(d(:)))
   z = zeros(0,1);  return
end
      
% Complex descriptor case not supported by MIMOZERO
if ~(isempty(e) || (isreal(a) && isreal(b) && isreal(c) && isreal(d) && isreal(e)))
   if rcond(e)<eps
       ctrlMsgUtils.error('Control:foundation:trzero1')
   else
      % Absorb E into A,B
      a = e\a;  b = e\b;  e = [];
   end
end

% Compute zeros
z = mimozero(a,b,c,d,e,tol);
