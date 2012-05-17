function boo = utIsIOScaling(D)
% True if D is of the form diag(dj*exp(-s*tauj)) where dj is a gain

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:33:14 $
[ny,nu] = size(D.num);
if ny~=nu || any(cellfun('length',D.num(:))>1)
   boo = false;
else
   num = cat(1,D.num{:});
   idx = 1:ny*nu;
   idx(1:nu+1:ny*nu) = [];  % off diagonal entries
   boo = ~(any(D.Delay.IO(idx)) || any(num(idx)));
end