function [z,g] = zero(D)
% Computes transmission zeros.

%   Clay M. Thompson  7-23-90, 
%   Revised:  P.Gahinet 5-15-96
%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:16 $
[ny,nu] = size(D.num);
if ny==0 || nu==0
   z = zeros(0,1);
   g = zeros(ny,nu);
elseif ny==1 && nu==1
   % SISO case
   num = D.num{1};
   if all(isfinite(num))
      z = roots(num);
      if nargout>1,
         % Compute the gain
         idx = find(D.den{1});
         den1 = D.den{1}(idx(1));
         num1 = num(end-length(z));
         g = num1/den1;
      end
   else
      z = zeros(0,1);
      g = NaN;
   end
else
   % MIMO case: convert to SS to compute transmission zeros
   z = zero(ss(D));
   g = [];
end

