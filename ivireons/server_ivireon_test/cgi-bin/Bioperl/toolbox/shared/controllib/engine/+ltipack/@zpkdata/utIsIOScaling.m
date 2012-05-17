function boo = utIsIOScaling(D)
% True if D is of the form diag(dj*exp(-s*tauj)) where dj is a gain

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:34:08 $
[ny,nu] = size(D.k);
if ny~=nu || any(cellfun('length',D.z(:))) || any(cellfun('length',D.p(:)))
   boo = false;
else
   idx = 1:ny*nu;
   idx(1:nu+1:ny*nu) = [];  % off diagonal entries
   boo = (ny==nu && ~any(D.Delay.IO(idx)) && ~any(D.k(idx)));
end