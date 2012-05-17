function boo = isfinite(D)
% Returns TRUE if model has finite data.

%   Copyright 1986-2003 The MathWorks, Inc.
%	 $Revision: 1.1.8.1 $  $Date: 2009/11/09 16:32:44 $
[ny,nu] = size(D.num);
for ct=1:ny*nu
   if ~all(isfinite(D.num{ct}))
      boo = false;
      return
   end
end
boo = true;
