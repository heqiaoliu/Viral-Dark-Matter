function minmax=xlim(fit)
%XLIM Return the X data limits for this fit

%   $Revision: 1.1.8.1 $  $Date: 2010/03/16 00:22:09 $
%   Copyright 2003-2004 The MathWorks, Inc.


ds = fit.dshandle;
if ~isempty(ds) & ~isempty(ds.x)
   x = getincludeddata(ds,fit.exclusionrule);
   minmax = [min(x) max(x)];
else
   minmax = [];
end

