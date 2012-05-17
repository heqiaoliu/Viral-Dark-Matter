function [z,g] = zero(D)
% Computes transmission zeros.

%   Clay M. Thompson  7-23-90, 
%   Revised:  P.Gahinet 5-15-96
%   Copyright 1986-2008 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:34:09 $
[ny,nu] = size(D.k);
if ny==0 || nu==0
   z = zeros(0,1);
   g = zeros(ny,nu);
elseif ny==1 && nu==1
   % SISO case
   z = D.z{1};
   g = D.k;
else
   % MIMO case: convert to SS to compute transmission zeros
   z = zero(ss(D));
   g = [];
end

