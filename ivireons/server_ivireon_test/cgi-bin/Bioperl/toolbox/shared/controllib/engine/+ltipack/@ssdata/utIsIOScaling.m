function boo = utIsIOScaling(D)
% True if D is of the form diag(dj*exp(-s*tauj))

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:06 $
[ny,nu] = size(D.d);
if isempty(D.a) && ny==nu && isempty(D.Delay.Internal)
   idx = 1:ny*nu;
   idx(1:nu+1:ny*nu) = [];  % off diagonal entries
   boo = ~any(D.d(idx));
else
   boo = false;
end
