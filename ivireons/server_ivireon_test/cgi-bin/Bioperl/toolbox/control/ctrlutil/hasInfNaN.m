function pf = hasInfNaN(x)
%HASINFNAN  Checks if array has Inf or NaN entries.
%
%   PF = HASINFNAN(X) returns true if X has any Inf or NaN entry.

%   Copyright 1986-2006 The MathWorks, Inc.
%   $Revision: 1.1.8.2 $ $Date: 2010/03/31 18:13:38 $
sx = 0;
for ct=1:numel(x)
   sx = sx + x(ct);
end
pf = ~isfinite(sx);